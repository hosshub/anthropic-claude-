-- v1.4 — مستويات الاشتراك وحدّ التحليلات حسب المستوى.
-- شغّله مرة واحدة في: Supabase ← SQL Editor ← New query ← الصق ← Run.
-- (الإعادة آمنة: يستخدم IF NOT EXISTS / OR REPLACE.)

-- ---------------------------------------------------------------------------
-- 1) جدول الاستحقاقات — يكتبه webhook من RevenueCat فقط.
-- ---------------------------------------------------------------------------
create table if not exists public.user_entitlements (
  user_id    uuid primary key,
  tier       text not null default 'free',      -- 'free' | 'premium'
  expires_at timestamptz,                       -- null = بلا انتهاء (مدى الحياة)
  source     text,                              -- 'revenuecat' | 'manual'
  updated_at timestamptz not null default now()
);

-- لا سياسات RLS → لا وصول للعميل؛ service_role فقط عبر الدوال أدناه.
alter table public.user_entitlements enable row level security;

-- ---------------------------------------------------------------------------
-- 2) تاريخ التحوّل من مدفوع إلى مجاني.
--
-- التطبيق كان مدفوعاً **ويشترط حساباً**، فكل حساب أُنشئ قبل هذا التاريخ يخصّ
-- مستخدماً دفع ثمنه فعلاً ⇒ مزايا كاملة مدى الحياة. التحقق هنا (لا في العميل)
-- حتى لا يمكن انتحاله.
-- ⚠️ حدّثه ليطابق تاريخ إصدار 1.4 الفعلي قبل النشر، وطابقه مع
--    paidEraCutoffDefault في lib/services/entitlement.dart.
-- ---------------------------------------------------------------------------
create or replace function public.paid_era_cutoff()
returns timestamptz
language sql
immutable
as $$ select '2026-08-01T00:00:00Z'::timestamptz $$;

-- ---------------------------------------------------------------------------
-- 3) المستوى الفعلي للمستخدم.
-- ---------------------------------------------------------------------------
create or replace function public.effective_tier(p_user uuid)
returns text
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  acct_created timestamptz;
  ent          record;
begin
  if p_user is null then
    return 'free';
  end if;

  -- المشترون القدامى: ترقية دائمة.
  select created_at into acct_created from auth.users where id = p_user;
  if acct_created is not null and acct_created < public.paid_era_cutoff() then
    return 'premium';
  end if;

  select tier, expires_at into ent
  from public.user_entitlements
  where user_id = p_user;

  if ent.tier = 'premium'
     and (ent.expires_at is null or ent.expires_at > now()) then
    return 'premium';
  end if;

  return 'free';
end;
$$;

grant execute on function public.effective_tier(uuid) to service_role;

-- ---------------------------------------------------------------------------
-- 4) عدّاد ضمن نافذة زمنية (يوم للمشتركين، أسبوع للمجانيين).
--
-- يُعيد: رقم موجب = مسموح (ترتيب التحليل داخل النافذة بعد الزيادة)،
--        رقم سالب = تجاوز الحدّ (القيمة المطلقة = المستهلك داخل النافذة).
-- القفل الاستشاري يمنع تجاوز الحدّ عند وصول طلبين متزامنين.
-- ---------------------------------------------------------------------------
create or replace function public.bump_usage_since(
  p_user  uuid,
  p_limit int,
  p_since date
)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  used int;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_user::text, 0));

  select coalesce(sum(count), 0) into used
  from public.usage_daily
  where user_id = p_user and day >= p_since;

  if used >= p_limit then
    return -used;
  end if;

  insert into public.usage_daily (user_id, day, count)
  values (p_user, current_date, 1)
  on conflict (user_id, day)
  do update set count = usage_daily.count + 1;

  return used + 1;
end;
$$;

grant execute on function public.bump_usage_since(uuid, int, date) to service_role;

-- ---------------------------------------------------------------------------
-- 5) upsert للاستحقاق — يستدعيه webhook من RevenueCat.
-- ---------------------------------------------------------------------------
create or replace function public.set_entitlement(
  p_user       uuid,
  p_tier       text,
  p_expires_at timestamptz,
  p_source     text default 'revenuecat'
)
returns void
language sql
security definer
set search_path = public
as $$
  insert into public.user_entitlements (user_id, tier, expires_at, source, updated_at)
  values (p_user, p_tier, p_expires_at, p_source, now())
  on conflict (user_id) do update
    set tier       = excluded.tier,
        expires_at = excluded.expires_at,
        source     = excluded.source,
        updated_at = now();
$$;

grant execute on function public.set_entitlement(uuid, text, timestamptz, text) to service_role;

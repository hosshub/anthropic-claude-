-- عدّاد التحليلات اليومي لكل مستخدم — حماية تكلفة وسيط Gemini.
-- شغّله مرة واحدة في: Supabase ← SQL Editor ← New query ← الصق ← Run.
-- (الإعادة آمنة: يستخدم IF NOT EXISTS / OR REPLACE.)

create table if not exists public.usage_daily (
  user_id uuid not null,
  day     date not null default current_date,
  count   int  not null default 0,
  primary key (user_id, day)
);

-- لا سياسات RLS → لا وصول للعميل العادي؛ الوسيط فقط (service_role) يكتب عبر الدالة أدناه.
alter table public.usage_daily enable row level security;

-- يزيد عدّاد اليوم ذرّياً ضمن حدّ p_limit.
-- يُعيد: رقم موجب = مسموح (رقم التحليل اليوم بعد الزيادة)،
--        رقم سالب = تجاوز الحدّ (القيمة المطلقة = العدد الحالي اليوم).
create or replace function public.bump_usage(p_user uuid, p_limit int)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  new_count int;
  cur_count int;
begin
  insert into public.usage_daily (user_id, day, count)
  values (p_user, current_date, 1)
  on conflict (user_id, day)
  do update set count = usage_daily.count + 1
  where usage_daily.count < p_limit
  returning count into new_count;

  if new_count is null then
    -- لم يُحدَّث الصف → بلغ الحدّ. أعِد العدد الحالي بإشارة سالبة.
    select count into cur_count
    from public.usage_daily
    where user_id = p_user and day = current_date;
    return -coalesce(cur_count, 0);
  end if;

  return new_count;
end;
$$;

grant execute on function public.bump_usage(uuid, int) to service_role;

-- يسترجع حصّة واحدة عند فشل التحليل (لا ينزل تحت صفر).
create or replace function public.refund_usage(p_user uuid)
returns void
language sql
security definer
set search_path = public
as $$
  update public.usage_daily
  set count = greatest(count - 1, 0)
  where user_id = p_user and day = current_date;
$$;

grant execute on function public.refund_usage(uuid) to service_role;

-- تنظيف اختياري للصفوف القديمة (شغّله يدوياً وقتما شئت):
--   delete from public.usage_daily where day < current_date - interval '7 days';

-- Wellness AI — initial schema (Supabase / Postgres)
-- Maps to docs/PRD.md §10 (data model). Consent is a first-class object.
-- Apply via: supabase db push  (or paste in the SQL editor).
--
-- NOTE: enable Row Level Security on every table and add policies before any
-- real data. Policies are sketched as comments; tighten before launch.

-- ---------------------------------------------------------------------------
-- Profiles (1:1 with auth.users) — consumer OR provider
-- ---------------------------------------------------------------------------
create type user_role as enum ('consumer', 'provider');
create type provider_kind as enum ('dietitian','physician','trainer','coach','clinic_admin');

create table profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  role          user_role not null default 'consumer',
  display_name  text,
  locale        text not null default 'ar',
  -- consumer personalization (lifestyle framing — not medical records)
  goals         text[] default '{}',
  condition_tags text[] default '{}',   -- e.g. {'diabetes','pcos','hypertension'}
  diet_tags     text[] default '{}',    -- e.g. {'keto','vegan','low_carb'}
  -- provider fields
  provider_kind provider_kind,
  practice_name text,
  created_at    timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Plans (elective / condition-informed / provider-prescribed)
-- ---------------------------------------------------------------------------
create type plan_source as enum ('elective','condition_informed','provider_prescribed');

create table plans (
  id               uuid primary key default gen_random_uuid(),
  owner_id         uuid references profiles(id) on delete set null, -- system/provider author
  assigned_to      uuid references profiles(id) on delete cascade,  -- the consumer following it
  source           plan_source not null default 'elective',
  title_ar         text not null,
  subtitle_ar      text,
  tags             text[] default '{}',
  target_calories  int,
  target_protein_g numeric,
  target_carbs_g   numeric,
  target_fat_g     numeric,
  target_sodium_mg numeric,
  rules_ar         text[] default '{}',
  is_active        boolean not null default true,
  created_at       timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Patient <-> Provider links (consent-first)
-- ---------------------------------------------------------------------------
create type link_status as enum ('invited','linked','unlinked');

create table invite_codes (
  code         text primary key,           -- short, shareable; or store QR payload
  provider_id  uuid not null references profiles(id) on delete cascade,
  reusable     boolean not null default false,
  expires_at   timestamptz,
  created_at   timestamptz not null default now()
);

create table provider_links (
  id            uuid primary key default gen_random_uuid(),
  provider_id   uuid not null references profiles(id) on delete cascade,
  patient_id    uuid not null references profiles(id) on delete cascade,
  status        link_status not null default 'linked',
  -- explicit consent scope: what the provider may see
  consent_meals       boolean not null default true,
  consent_activity    boolean not null default true,
  consent_body_logs   boolean not null default true,
  linked_at     timestamptz not null default now(),
  unlinked_at   timestamptz,
  unique (provider_id, patient_id)
);

-- ---------------------------------------------------------------------------
-- Meals + items (AI analysis output, with user corrections)
-- ---------------------------------------------------------------------------
create type fit_zone as enum ('green','amber','red');

create table meals (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references profiles(id) on delete cascade,
  plan_id       uuid references plans(id) on delete set null,
  captured_at   timestamptz not null default now(),
  image_path    text,                       -- storage ref (private bucket)
  overall_score int not null default 0,     -- 0–100 plan-fit
  score_label_ar text default '',
  reasoning_ar  text default '',
  was_edited    boolean not null default false
);

create table food_items (
  id               uuid primary key default gen_random_uuid(),
  meal_id          uuid not null references meals(id) on delete cascade,
  name_ar          text not null,
  name_en          text,
  estimated_portion text,
  confidence       numeric,
  zone             fit_zone not null default 'amber',
  reasoning_ar     text,
  calories         int,
  protein_g        numeric,
  carbs_g          numeric,
  fat_g            numeric,
  sodium_mg        numeric,
  item_order       int not null default 0
);

-- ---------------------------------------------------------------------------
-- Body / wellness logs + wearable data + messages
-- ---------------------------------------------------------------------------
create table body_logs (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles(id) on delete cascade,
  meal_id     uuid references meals(id) on delete set null,
  logged_at   timestamptz not null default now(),
  energy      int,    -- 1..5
  digestion   int,    -- 0..5 (bloating/discomfort)
  sleep_impact text,  -- positive/neutral/negative/unknown
  symptoms    text[]  default '{}',  -- GLP-1 symptom logging, etc.
  notes       text
);

create table wearable_daily (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles(id) on delete cascade,
  day         date not null,
  steps       int,
  active_kcal int,
  resting_hr  int,
  sleep_min   int,
  glucose_avg numeric,  -- if a CGM is connected (read-only context)
  source      text,     -- 'apple_health' | 'health_connect' | 'fitbit' | 'terra:<provider>'
  unique (user_id, day, source)
);

create table messages (
  id          uuid primary key default gen_random_uuid(),
  link_id     uuid not null references provider_links(id) on delete cascade,
  sender_id   uuid not null references profiles(id) on delete cascade,
  body        text not null,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Usage counter for the free-tier daily AI scan cap (refund-on-failure)
-- ---------------------------------------------------------------------------
create table usage_daily (
  user_id  uuid not null references profiles(id) on delete cascade,
  day      date not null,
  scans    int not null default 0,
  primary key (user_id, day)
);

-- bump/refund RPCs (called by the analyze edge function)
create or replace function bump_usage(p_user uuid, p_cap int)
returns boolean language plpgsql security definer as $$
declare current int;
begin
  insert into usage_daily(user_id, day, scans) values (p_user, current_date, 0)
    on conflict (user_id, day) do nothing;
  select scans into current from usage_daily where user_id = p_user and day = current_date for update;
  if current >= p_cap then return false; end if;
  update usage_daily set scans = scans + 1 where user_id = p_user and day = current_date;
  return true;
end $$;

create or replace function refund_usage(p_user uuid)
returns void language plpgsql security definer as $$
begin
  update usage_daily set scans = greatest(scans - 1, 0)
   where user_id = p_user and day = current_date;
end $$;

-- ---------------------------------------------------------------------------
-- RLS (enable + sketch). TIGHTEN before launch.
-- ---------------------------------------------------------------------------
alter table profiles        enable row level security;
alter table plans           enable row level security;
alter table provider_links  enable row level security;
alter table invite_codes    enable row level security;
alter table meals           enable row level security;
alter table food_items      enable row level security;
alter table body_logs       enable row level security;
alter table wearable_daily  enable row level security;
alter table messages        enable row level security;
alter table usage_daily     enable row level security;

-- Example policies (expand): a user sees their own rows; a provider sees a
-- patient's rows only via an active provider_links row with the right consent.
-- create policy "own profile" on profiles for all using (id = auth.uid());
-- create policy "own meals"   on meals    for all using (user_id = auth.uid());
-- create policy "provider sees consented meals" on meals for select using (
--   exists (select 1 from provider_links pl
--           where pl.patient_id = meals.user_id
--             and pl.provider_id = auth.uid()
--             and pl.status = 'linked'
--             and pl.consent_meals));

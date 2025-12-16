-- ===============================
-- EXTENSIONS
-- ===============================
create extension if not exists "uuid-ossp";

-- ===============================
-- USER PROFILES
-- Extends auth.users
-- ===============================
create table if not exists public.user_profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    first_name text,
    last_name text,
    role text check (role in ('owner', 'admin', 'member')),
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- ===============================
-- BUSINESSES
-- Core tenant entity
-- ===============================
create table if not exists public.businesses (
    id bigserial primary key,
    name text not null,
    industry text,
    timezone text,
    default_reply_tone text,
    review_auto_import_enabled boolean default true,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- ===============================
-- USER ↔ BUSINESS ROLES
-- Multi-tenant access control
-- ===============================
create table if not exists public.user_business_roles (
    id bigserial primary key,
    user_id uuid not null references public.user_profiles(id) on delete cascade,
    business_id bigint not null references public.businesses(id) on delete cascade,
    role text check (role in ('owner', 'admin', 'staff', 'viewer')),
    created_at timestamptz default now(),
    unique (user_id, business_id)
);

create index if not exists idx_user_business_roles_user
    on public.user_business_roles (user_id);

create index if not exists idx_user_business_roles_business
    on public.user_business_roles (business_id);

-- ===============================
-- REVIEW SOURCES
-- Google, Yelp, Manual, etc.
-- ===============================
create table if not exists public.review_sources (
    id bigserial primary key,
    name text not null,
    type text not null, -- api, webhook, scraper, manual
    created_at timestamptz default now()
);

-- ===============================
-- REVIEWS
-- Central domain entity
-- ===============================
create table if not exists public.reviews (
    id bigserial primary key,
    business_id bigint not null references public.businesses(id) on delete cascade,
    source_id bigint references public.review_sources(id),
    source_review_id text,
    author_name text,
    rating int check (rating between 1 and 5),
    title text,
    body text,
    language text,
    sentiment text,
    posted_at timestamptz,
    ingested_at timestamptz default now(),
    unique (source_review_id, source_id)
);

create index if not exists idx_reviews_business
    on public.reviews (business_id);

create index if not exists idx_reviews_rating
    on public.reviews (rating);

create index if not exists idx_reviews_posted_at
    on public.reviews (posted_at);


-- V9: Academy table and user academy_number
-- Creates academy table and adds academy_number to app_user

create table if not exists academy (
  id bigserial primary key,
  academy_number bigint unique not null,
  name text not null,
  logo_url text null,
  primary_color text null,
  created_at timestamptz not null default now()
);

create index if not exists idx_academy_number on academy(academy_number);

alter table app_user add column if not exists academy_number bigint null;

alter table app_user 
  add constraint fk_user_academy 
  foreign key (academy_number) 
  references academy(academy_number);

create index if not exists idx_user_academy_number on app_user(academy_number);

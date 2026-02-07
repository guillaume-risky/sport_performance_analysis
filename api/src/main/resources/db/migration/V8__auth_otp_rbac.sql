-- V8: Auth tables for OTP and sessions.
-- app_user already exists in this system with id bigint.

create table if not exists otp_challenge (
  id uuid primary key,
  email varchar(320) not null,
  purpose varchar(40) not null,
  code_hash varchar(255) not null,
  expires_at timestamptz not null,
  attempts int not null default 0,
  consumed boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_otp_email on otp_challenge(email);
create index if not exists idx_otp_expires on otp_challenge(expires_at);

create table if not exists user_session (
  id uuid primary key,
  user_id bigint not null references app_user(id) on delete cascade,
  jwt_id uuid not null unique,
  expires_at timestamptz not null,
  revoked boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_session_user on user_session(user_id);

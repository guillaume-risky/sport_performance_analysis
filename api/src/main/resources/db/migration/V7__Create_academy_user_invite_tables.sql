-- V7, Make app_user and invite_token schema consistent, link via academy_number
-- This is idempotent, safe to re run even if tables already exist

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Ensure app_user exists (minimal)
CREATE TABLE IF NOT EXISTS app_user (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid()
);

-- Add missing columns to app_user
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='app_user' AND column_name='user_number') THEN
    ALTER TABLE app_user ADD COLUMN user_number VARCHAR(30);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='app_user' AND column_name='academy_number') THEN
    ALTER TABLE app_user ADD COLUMN academy_number VARCHAR(30);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='app_user' AND column_name='email') THEN
    ALTER TABLE app_user ADD COLUMN email VARCHAR(255);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='app_user' AND column_name='role') THEN
    ALTER TABLE app_user ADD COLUMN role VARCHAR(30);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='app_user' AND column_name='is_active') THEN
    ALTER TABLE app_user ADD COLUMN is_active BOOLEAN;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='app_user' AND column_name='created_at') THEN
    ALTER TABLE app_user ADD COLUMN created_at TIMESTAMPTZ;
  END IF;

  -- Backfill defaults where null, so future logic does not break
  UPDATE app_user SET is_active = true WHERE is_active IS NULL;
  UPDATE app_user SET created_at = NOW() WHERE created_at IS NULL;
  UPDATE app_user SET role = 'PLAYER' WHERE role IS NULL;

  -- Set defaults (safe, even if rows exist)
  ALTER TABLE app_user ALTER COLUMN is_active SET DEFAULT true;
  ALTER TABLE app_user ALTER COLUMN created_at SET DEFAULT NOW();
  ALTER TABLE app_user ALTER COLUMN role SET DEFAULT 'PLAYER';
END $$;

-- Unique constraints only if column exists, do not force NOT NULL here (avoids failing on existing rows)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='app_user' AND column_name='user_number') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='uq_app_user_user_number') THEN
      ALTER TABLE app_user ADD CONSTRAINT uq_app_user_user_number UNIQUE (user_number);
    END IF;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='app_user' AND column_name='email') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='uq_app_user_email') THEN
      ALTER TABLE app_user ADD CONSTRAINT uq_app_user_email UNIQUE (email);
    END IF;
  END IF;
END $$;

-- Indexes for app_user
CREATE INDEX IF NOT EXISTS idx_user_number ON app_user(user_number);
CREATE INDEX IF NOT EXISTS idx_user_email ON app_user(email);
CREATE INDEX IF NOT EXISTS idx_user_academy_number ON app_user(academy_number);
CREATE INDEX IF NOT EXISTS idx_user_role ON app_user(role);
CREATE INDEX IF NOT EXISTS idx_user_active ON app_user(is_active);

-- invite_token table, create if missing
CREATE TABLE IF NOT EXISTS invite_token (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  token VARCHAR(80),
  academy_number VARCHAR(30),
  email VARCHAR(255),
  role VARCHAR(30),
  expires_at TIMESTAMPTZ,
  used_at TIMESTAMPTZ NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add missing columns to invite_token if it already existed
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='invite_token' AND column_name='token') THEN
    ALTER TABLE invite_token ADD COLUMN token VARCHAR(80);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='invite_token' AND column_name='academy_number') THEN
    ALTER TABLE invite_token ADD COLUMN academy_number VARCHAR(30);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='invite_token' AND column_name='email') THEN
    ALTER TABLE invite_token ADD COLUMN email VARCHAR(255);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='invite_token' AND column_name='role') THEN
    ALTER TABLE invite_token ADD COLUMN role VARCHAR(30);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='invite_token' AND column_name='expires_at') THEN
    ALTER TABLE invite_token ADD COLUMN expires_at TIMESTAMPTZ;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='invite_token' AND column_name='used_at') THEN
    ALTER TABLE invite_token ADD COLUMN used_at TIMESTAMPTZ NULL;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='invite_token' AND column_name='created_at') THEN
    ALTER TABLE invite_token ADD COLUMN created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
  END IF;
END $$;

-- Make token unique if not already
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='uq_invite_token_token') THEN
    ALTER TABLE invite_token ADD CONSTRAINT uq_invite_token_token UNIQUE (token);
  END IF;
END $$;

-- Indexes for invite_token
CREATE INDEX IF NOT EXISTS idx_invite_token_token ON invite_token(token);
CREATE INDEX IF NOT EXISTS idx_invite_token_expires_at ON invite_token(expires_at);
CREATE INDEX IF NOT EXISTS idx_invite_token_academy_number ON invite_token(academy_number);
CREATE INDEX IF NOT EXISTS idx_invite_token_email ON invite_token(email);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = 'idx_invite_token_used_at_null' AND n.nspname = 'public'
  ) THEN
    CREATE INDEX idx_invite_token_used_at_null ON invite_token(used_at) WHERE used_at IS NULL;
  END IF;
END $$;

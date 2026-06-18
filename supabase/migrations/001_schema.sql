-- 001_schema.sql
-- Core tables for The Ledger — Belle's Lounge bar prep management system.

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- STAFF
-- ============================================================
CREATE TABLE staff (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT        NOT NULL,
  pin_hash   TEXT        NOT NULL,           -- bcrypt hash of 4-digit PIN
  is_admin   BOOLEAN     NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- ITEMS  (par items — what needs to be stocked)
-- ============================================================
CREATE TABLE items (
  id                     UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name                   TEXT        NOT NULL UNIQUE,
  category               TEXT        NOT NULL,   -- 'syrups_infusions' | 'juices' | 'garnishes'
  par_level              NUMERIC     NOT NULL CHECK (par_level > 0),
  stock_unit             TEXT        NOT NULL DEFAULT 'batches',   -- 'batches' | 'containers' | 'liters'
  container_volume_liters NUMERIC,              -- required when stock_unit = 'containers'
  is_active              BOOLEAN     NOT NULL DEFAULT true,
  created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT items_container_volume_required
    CHECK (stock_unit <> 'containers' OR container_volume_liters IS NOT NULL)
);

-- ============================================================
-- RECIPES
-- ============================================================
CREATE TABLE recipes (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name             TEXT        NOT NULL,
  base_yield_liters NUMERIC    NOT NULL CHECK (base_yield_liters > 0),
  notes            TEXT,                        -- optional ratio/seasonal notes
  archived_at      TIMESTAMPTZ,                 -- NULL = active; set to archive
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- RECIPE INGREDIENTS
-- NOTE: quantity + unit — not quantity_liters — because ingredients
-- include kg, lbs, oz, cups, tablespoons, etc. as well as liters.
-- Scaling multiplies quantity by the yield factor; unit stays fixed.
-- ============================================================
CREATE TABLE recipe_ingredients (
  id         UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id  UUID    NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  name       TEXT    NOT NULL,
  quantity   NUMERIC NOT NULL CHECK (quantity > 0),
  unit       TEXT    NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0
);

-- ============================================================
-- RECIPE STEPS
-- ============================================================
CREATE TABLE recipe_steps (
  id          UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id   UUID    NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  step_order  INTEGER NOT NULL,
  instruction TEXT    NOT NULL
);

-- ============================================================
-- BATCHES  (log of what was prepped)
-- ============================================================
CREATE TABLE batches (
  id           UUID        PRIMARY KEY,          -- client-generated UUID for idempotent offline sync
  item_id      UUID        NOT NULL REFERENCES items(id),
  recipe_id    UUID        REFERENCES recipes(id),
  staff_id     UUID        NOT NULL REFERENCES staff(id),
  yield_liters NUMERIC     NOT NULL CHECK (yield_liters > 0),
  scale_factor NUMERIC     NOT NULL DEFAULT 1.0 CHECK (scale_factor > 0),
  notes        TEXT,
  logged_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- WASTE LOGS
-- ============================================================
CREATE TABLE waste_logs (
  id           UUID        PRIMARY KEY,          -- client-generated UUID for idempotent offline sync
  item_id      UUID        NOT NULL REFERENCES items(id),
  staff_id     UUID        NOT NULL REFERENCES staff(id),
  quantity     NUMERIC     NOT NULL CHECK (quantity > 0),
  unit         TEXT        NOT NULL,
  reason       TEXT,
  logged_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- PARS CHECK SESSIONS
-- ============================================================
CREATE TABLE pars_check_sessions (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id     UUID        NOT NULL REFERENCES staff(id),
  session_date DATE        NOT NULL,             -- America/Detroit date — used as PK surrogate for daily uniqueness
  completed_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE (staff_id, session_date)
);

-- ============================================================
-- PAR PRESETS  (seasonal par snapshots)
-- ============================================================
CREATE TABLE par_presets (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT        NOT NULL,
  par_snapshot JSONB       NOT NULL,             -- { "item_id": par_level, ... }
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  activated_at TIMESTAMPTZ                       -- set each time the preset is activated
);

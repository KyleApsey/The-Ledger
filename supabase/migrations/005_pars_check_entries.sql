-- 005_pars_check_entries.sql
-- Stock check entries for daily prep session tracking.

-- Change session uniqueness from per-staff to per-day (whole-location session)
-- staff_id is kept to record who initiated the check
ALTER TABLE pars_check_sessions
  DROP CONSTRAINT pars_check_sessions_staff_id_session_date_key;
ALTER TABLE pars_check_sessions
  ADD CONSTRAINT pars_check_sessions_date_key UNIQUE (session_date);

-- Per-item stock quantities recorded during a stock check session
CREATE TABLE pars_check_entries (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id     UUID        NOT NULL REFERENCES pars_check_sessions(id) ON DELETE CASCADE,
  item_id        UUID        NOT NULL REFERENCES items(id),
  stock_quantity NUMERIC     NOT NULL CHECK (stock_quantity >= 0),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE (session_id, item_id)
);

CREATE INDEX pars_check_entries_session_idx ON pars_check_entries (session_id);

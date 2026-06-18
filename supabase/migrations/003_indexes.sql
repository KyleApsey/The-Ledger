-- 003_indexes.sql
-- Performance indexes.
-- IF NOT EXISTS makes this migration safe to re-apply (e.g. after a partial failure).

CREATE INDEX IF NOT EXISTS items_is_active_idx
  ON items (id)
  WHERE is_active = true;

CREATE INDEX IF NOT EXISTS recipes_active_idx
  ON recipes (id)
  WHERE archived_at IS NULL;

CREATE INDEX IF NOT EXISTS recipe_ingredients_name_idx
  ON recipe_ingredients (name);

CREATE INDEX IF NOT EXISTS batches_item_id_idx
  ON batches (item_id);

CREATE INDEX IF NOT EXISTS batches_staff_id_idx
  ON batches (staff_id);

CREATE INDEX IF NOT EXISTS pars_sessions_date_idx
  ON pars_check_sessions (session_date);

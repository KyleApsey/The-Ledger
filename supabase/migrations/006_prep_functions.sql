-- 006_prep_functions.sql
-- RPCs for stock check session management and deficit-aware item listing.

-- upsert_stock_check: atomic find-or-create session + upsert all entries.
-- Handles the race condition where two devices submit simultaneously by keying
-- on session_date rather than client-generated UUIDs.
CREATE OR REPLACE FUNCTION upsert_stock_check(
  p_date     DATE,
  p_staff_id UUID,
  p_entries  JSONB   -- [{ "item_id": "...", "stock_quantity": 1.5 }, ...]
) RETURNS UUID AS $$
DECLARE
  v_session_id UUID;
BEGIN
  INSERT INTO pars_check_sessions (staff_id, session_date)
  VALUES (p_staff_id, p_date)
  ON CONFLICT (session_date) DO NOTHING;

  SELECT id INTO v_session_id
  FROM pars_check_sessions
  WHERE session_date = p_date;

  INSERT INTO pars_check_entries (session_id, item_id, stock_quantity)
  SELECT
    v_session_id,
    (e->>'item_id')::UUID,
    (e->>'stock_quantity')::NUMERIC
  FROM jsonb_array_elements(p_entries) AS e
  ON CONFLICT (session_id, item_id)
    DO UPDATE SET stock_quantity = EXCLUDED.stock_quantity;

  RETURN v_session_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- get_items_with_deficit: returns active items with deficit calculation.
-- When a stock check session exists for p_date, items include stock_quantity
-- and deficit. When no session exists, all items return needs_prep=true with
-- deficit=0 (preserving the pre-stock-check checklist behavior).
CREATE OR REPLACE FUNCTION get_items_with_deficit(p_date DATE)
RETURNS TABLE (
  id                UUID,
  name              TEXT,
  category          TEXT,
  par_level         NUMERIC,
  stock_unit        TEXT,
  recipe_id         UUID,
  recipe_name       TEXT,
  base_yield_liters NUMERIC,
  batched_today     BOOLEAN,
  stock_quantity    NUMERIC,
  deficit           NUMERIC,
  needs_prep        BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    i.id,
    i.name,
    i.category,
    i.par_level,
    i.stock_unit,
    r.id                                                        AS recipe_id,
    r.name                                                      AS recipe_name,
    r.base_yield_liters,
    EXISTS(
      SELECT 1 FROM batches b
      WHERE b.item_id = i.id
        AND DATE(b.logged_at AT TIME ZONE 'America/Detroit') = p_date
    )                                                           AS batched_today,
    pce.stock_quantity,
    GREATEST(0, i.par_level - COALESCE(pce.stock_quantity, i.par_level))
                                                                AS deficit,
    CASE
      WHEN pce.stock_quantity IS NULL THEN true   -- no session: show all
      ELSE pce.stock_quantity < i.par_level
    END                                                         AS needs_prep
  FROM items i
  LEFT JOIN recipes r
    ON r.item_id = i.id AND r.archived_at IS NULL
  LEFT JOIN pars_check_sessions pcs
    ON pcs.session_date = p_date
  LEFT JOIN pars_check_entries pce
    ON pce.session_id = pcs.id AND pce.item_id = i.id
  WHERE i.is_active = true
  ORDER BY i.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

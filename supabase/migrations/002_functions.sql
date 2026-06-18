-- 002_functions.sql
-- PostgreSQL functions for operations that require transactions or DISTINCT queries.
-- Called from Nitro server routes via supabase.rpc().

-- ============================================================
-- activate_par_preset
-- Writes par_level from a preset's snapshot directly to items.
-- Runs in a single transaction — all-or-nothing.
-- Returns JSON { updated: N, skipped: M }
-- Skipped = item_id in snapshot that no longer exists in items table.
-- ============================================================
CREATE OR REPLACE FUNCTION activate_par_preset(p_preset_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_snapshot  JSONB;
  v_item_id   UUID;
  v_par_level NUMERIC;
  v_updated   INT := 0;
  v_skipped   INT := 0;
BEGIN
  SELECT par_snapshot INTO v_snapshot
  FROM par_presets
  WHERE id = p_preset_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'preset_not_found' USING ERRCODE = 'P0001';
  END IF;

  FOR v_item_id, v_par_level IN
    SELECT key::UUID, value::NUMERIC
    FROM jsonb_each_text(v_snapshot)
  LOOP
    UPDATE items
    SET par_level = v_par_level
    WHERE id = v_item_id;

    IF FOUND THEN
      v_updated := v_updated + 1;
    ELSE
      v_skipped := v_skipped + 1;
    END IF;
  END LOOP;

  UPDATE par_presets
  SET activated_at = now()
  WHERE id = p_preset_id;

  RETURN json_build_object('updated', v_updated, 'skipped', v_skipped);
END;
$$;

-- ============================================================
-- duplicate_recipe
-- Deep-copies a recipe with all its ingredients and steps.
-- New recipe gets a new UUID, name = "Copy of [Original]",
-- archived_at = NULL (active draft).
-- Returns the new recipe UUID.
-- ============================================================
CREATE OR REPLACE FUNCTION duplicate_recipe(p_recipe_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_new_id UUID := gen_random_uuid();
BEGIN
  INSERT INTO recipes (id, name, base_yield_liters, notes, archived_at, created_at)
  SELECT
    v_new_id,
    'Copy of ' || name,
    base_yield_liters,
    notes,
    NULL,
    now()
  FROM recipes
  WHERE id = p_recipe_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'recipe_not_found' USING ERRCODE = 'P0002';
  END IF;

  INSERT INTO recipe_ingredients (id, recipe_id, name, quantity, unit, sort_order)
  SELECT gen_random_uuid(), v_new_id, name, quantity, unit, sort_order
  FROM recipe_ingredients
  WHERE recipe_id = p_recipe_id;

  INSERT INTO recipe_steps (id, recipe_id, step_order, instruction)
  SELECT gen_random_uuid(), v_new_id, step_order, instruction
  FROM recipe_steps
  WHERE recipe_id = p_recipe_id;

  RETURN v_new_id;
END;
$$;

-- ============================================================
-- get_ingredient_suggestions
-- Returns distinct ingredient names matching a prefix string.
-- Used for the admin recipe form ingredient autocomplete.
-- Triggered at 2+ characters; returns max 20 matches.
-- ============================================================
CREATE OR REPLACE FUNCTION get_ingredient_suggestions(q TEXT)
RETURNS TABLE(name TEXT)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT DISTINCT ri.name
  FROM recipe_ingredients ri
  WHERE ri.name ILIKE q || '%'
  ORDER BY ri.name
  LIMIT 20;
$$;

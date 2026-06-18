-- 007_create_recipe.sql
-- Atomic multi-table insert for a new recipe with ingredients and steps.
-- Called from POST /api/admin/recipes via supabase.rpc().
CREATE OR REPLACE FUNCTION create_recipe(
  p_name              TEXT,
  p_base_yield_liters NUMERIC,
  p_item_id           UUID    DEFAULT NULL,
  p_notes             TEXT    DEFAULT NULL,
  p_ingredients       JSONB   DEFAULT '[]',
  p_steps             JSONB   DEFAULT '[]'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_new_id    UUID := gen_random_uuid();
  v_ingredient JSONB;
  v_step      JSONB;
  v_order     INT;
BEGIN
  INSERT INTO recipes (id, name, base_yield_liters, item_id, notes, created_at)
  VALUES (v_new_id, p_name, p_base_yield_liters, p_item_id, p_notes, now());

  v_order := 1;
  FOR v_ingredient IN SELECT * FROM jsonb_array_elements(p_ingredients)
  LOOP
    INSERT INTO recipe_ingredients (id, recipe_id, name, quantity, unit, sort_order)
    VALUES (
      gen_random_uuid(),
      v_new_id,
      v_ingredient->>'name',
      (v_ingredient->>'quantity')::NUMERIC,
      v_ingredient->>'unit',
      v_order
    );
    v_order := v_order + 1;
  END LOOP;

  v_order := 1;
  FOR v_step IN SELECT * FROM jsonb_array_elements(p_steps)
  LOOP
    INSERT INTO recipe_steps (id, recipe_id, step_order, instruction)
    VALUES (
      gen_random_uuid(),
      v_new_id,
      v_order,
      v_step->>'instruction'
    );
    v_order := v_order + 1;
  END LOOP;

  RETURN v_new_id;
END;
$$;

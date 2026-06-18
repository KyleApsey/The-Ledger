CREATE OR REPLACE FUNCTION undo_batch(p_item_id UUID, p_date DATE)
RETURNS TABLE (batched_today BOOLEAN) AS $$
DECLARE
  v_batch_id UUID;
BEGIN
  -- FOR UPDATE prevents a concurrent batch insert from racing between SELECT and DELETE
  SELECT id INTO v_batch_id
  FROM batches
  WHERE item_id = p_item_id
    AND DATE(logged_at AT TIME ZONE 'America/Detroit') = p_date
  ORDER BY logged_at DESC
  LIMIT 1
  FOR UPDATE;

  IF v_batch_id IS NOT NULL THEN
    DELETE FROM batches WHERE id = v_batch_id;
  END IF;

  RETURN QUERY
  SELECT EXISTS(
    SELECT 1 FROM batches
    WHERE item_id = p_item_id
      AND DATE(logged_at AT TIME ZONE 'America/Detroit') = p_date
  ) AS batched_today;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

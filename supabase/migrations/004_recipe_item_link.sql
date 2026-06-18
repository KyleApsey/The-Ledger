-- Link recipes back to the item they produce.
-- A recipe may exist without an item (seasonal/specialty), so nullable FK.
ALTER TABLE recipes
  ADD COLUMN item_id UUID REFERENCES items(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS recipes_item_id_idx ON recipes (item_id) WHERE archived_at IS NULL;

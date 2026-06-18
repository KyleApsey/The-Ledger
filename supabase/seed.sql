-- seed.sql
-- Initial data for The Ledger.
-- Run by: supabase db reset (local) or applied once in production.
-- Par levels default to 1 batch — adjust via the admin interface after launch.

-- ============================================================
-- ITEMS  (31 par items from RAW_PARS.md)
-- ============================================================
INSERT INTO items (name, category, par_level, stock_unit, is_active) VALUES
  -- Syrups & Infusions
  ('Simple syrup',                    'syrups_infusions', 1, 'batches', true),
  ('Brown sugar simple syrup',        'syrups_infusions', 1, 'batches', true),
  ('Mint simple syrup',               'syrups_infusions', 1, 'batches', true),
  ('Basil simple syrup',              'syrups_infusions', 1, 'batches', true),
  ('Ginger simple syrup',             'syrups_infusions', 1, 'batches', true),
  ('Lapsang Souchong Infused Rye',    'syrups_infusions', 1, 'batches', true),
  ('Honey simple syrup',              'syrups_infusions', 1, 'batches', true),
  ('Maple simple syrup',              'syrups_infusions', 1, 'batches', true),
  ('Cucumber infused vodka',          'syrups_infusions', 1, 'batches', true),
  ('Tre pepper infused vodka',        'syrups_infusions', 1, 'batches', true),
  ('Bloody mary mix',                 'syrups_infusions', 1, 'batches', true),
  ('Coffee liqueur',                  'syrups_infusions', 1, 'batches', true),
  ('Grenadine',                       'syrups_infusions', 1, 'batches', true),
  ('Bourbon creme',                   'syrups_infusions', 1, 'batches', true),
  ('Strawberry vanilla simple syrup', 'syrups_infusions', 1, 'batches', true),
  ('Pistachio orgeat',                'syrups_infusions', 1, 'batches', true),
  ('Vanilla simple syrup',            'syrups_infusions', 1, 'batches', true),
  ('Raspberry simple syrup',          'syrups_infusions', 1, 'batches', true),
  ('Bubblegum simple syrup',          'syrups_infusions', 1, 'batches', true),
  ('Mint tea',                        'syrups_infusions', 1, 'batches', true),
  ('Passion fruit tea',               'syrups_infusions', 1, 'batches', true),
  ('Orange oleo',                     'syrups_infusions', 1, 'batches', true),
  -- Juices
  ('Orange juice',    'juices', 1, 'batches', true),
  ('Grapefruit juice','juices', 1, 'batches', true),
  -- Garnishes
  ('Lemon wheels',       'garnishes', 1, 'batches', true),
  ('Lime wheels',        'garnishes', 1, 'batches', true),
  ('Dried lemon wheels', 'garnishes', 1, 'batches', true),
  ('Dried lime wheels',  'garnishes', 1, 'batches', true),
  ('Blue cheese olives', 'garnishes', 1, 'batches', true),
  ('Jalapeno olives',    'garnishes', 1, 'batches', true),
  ('Habenero rings',     'garnishes', 1, 'batches', true)
ON CONFLICT (name) DO NOTHING;

-- ============================================================
-- RECIPES  (31 recipes from RAW_RECIPES.md)
-- Using CTEs to reference recipe IDs for ingredient/step inserts.
-- ============================================================

-- Simple Syrup
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters) VALUES ('Simple Syrup', 3) RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES
    (1, 'white/cane sugar', 1.5, 'kg'),
    (2, 'water',            1.5, 'L')
  ) AS i(sort_order, name, quantity, unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Simple Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1, 'Combine sugar and water in a stock pot.'),
    (2, 'Bring to a boil.'),
    (3, 'Stir to ensure sugar is dissolved.'),
    (4, 'Turn off heat.'),
    (5, 'Let cool for 30 minutes.'),
    (6, 'Pour into container.'),
    (7, 'Add 1.5oz vodka for preservation.')
  ) AS s(step_order, instruction);

-- Brown Sugar Simple Syrup
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters) VALUES ('Brown Sugar Simple Syrup', 4) RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'brown sugar',4,'lbs'),(2,'water',2.5,'L')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Brown Sugar Simple Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine sugar and water in a stock pot.'),
    (2,'Bring to a boil.'),
    (3,'Stir to ensure sugar is dissolved.'),
    (4,'Turn off heat.'),
    (5,'Let cool for 30 minutes.'),
    (6,'Pour into container.'),
    (7,'Add 1.5oz vodka for preservation.')
  ) AS s(step_order,instruction);

-- Ginger Simple Syrup
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Ginger Simple Syrup', 4, 'Ratio 1:1:2 (Ginger juice:Water:Sugar)') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'ginger juice',1,'L'),(2,'water',1,'L'),(3,'white/cane sugar',2,'kg')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Ginger Simple Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Using centrifugal juicer, extract juice from ginger.'),
    (2,'Squeeze pulp with hand juice press.'),
    (3,'Combine ginger juice, water, and sugar in a stock pot.'),
    (4,'Bring to a boil.'),
    (5,'Stir to ensure sugar is dissolved.'),
    (6,'Turn off heat.'),
    (7,'Let cool for 30 minutes.'),
    (8,'Pour into container.'),
    (9,'Add 1.5oz vodka for preservation.')
  ) AS s(step_order,instruction);

-- Basil Simple Syrup
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Basil Simple Syrup', 4, 'Ratio 1:1 (Sugar:Water)') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'fresh basil leaves',10,'oz'),(2,'water',2,'L'),(3,'white/cane sugar',2,'kg')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Basil Simple Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine sugar and water in a stock pot.'),
    (2,'Bring to a boil.'),
    (3,'Stir to ensure sugar is dissolved.'),
    (4,'Add basil leaves.'),
    (5,'Return to a boil.'),
    (6,'Turn off heat.'),
    (7,'Let cool for 30 minutes.'),
    (8,'Strain into container.'),
    (9,'Add 1.5oz vodka for preservation.')
  ) AS s(step_order,instruction);

-- Mint Simple Syrup
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Mint Simple Syrup', 4, 'Ratio 1:1 (Sugar:Water)') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'fresh mint leaves',15,'oz'),(2,'water',2,'L'),(3,'white/cane sugar',2,'kg')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Mint Simple Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine sugar and water in a stock pot.'),
    (2,'Bring to a boil.'),
    (3,'Stir to ensure sugar is dissolved.'),
    (4,'Add mint leaves.'),
    (5,'Return to a boil.'),
    (6,'Turn off heat.'),
    (7,'Let cool for 30 minutes.'),
    (8,'Strain into container.'),
    (9,'Add 1.5oz vodka for preservation.')
  ) AS s(step_order,instruction);

-- Honey Simple Syrup
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Honey Simple Syrup', 2.5, 'Ratio 3:2 (Honey:Water)') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'honey',90,'oz'),(2,'water',1,'L')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Honey Simple Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine honey and water in a stock pot.'),
    (2,'Bring to a boil.'),
    (3,'Stir to ensure honey is dissolved.'),
    (4,'Turn off heat.'),
    (5,'Let cool for 30 minutes.'),
    (6,'Pour into container.'),
    (7,'Add 1.5oz vodka for preservation.')
  ) AS s(step_order,instruction);

-- Lavender Simple Syrup (seasonal)
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Lavender Simple Syrup', 2, 'Ratio 1:1 (Sugar:Water). Seasonal.') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'lavender',1.2,'oz'),(2,'water',1,'L'),(3,'white/cane sugar',1,'kg')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Lavender Simple Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine sugar and water in a stock pot.'),
    (2,'Bring to a boil.'),
    (3,'Stir to ensure sugar is dissolved.'),
    (4,'Add lavender.'),
    (5,'Return to a boil.'),
    (6,'Turn off heat.'),
    (7,'Let cool for 30 minutes.'),
    (8,'Strain into container.'),
    (9,'Add 1.5oz vodka for preservation.')
  ) AS s(step_order,instruction);

-- Lapsang Souchong Infused Sweet Vermouth (seasonal)
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Lapsang Souchong Infused Sweet Vermouth', 2, 'Seasonal.') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'Cocchi Di Torino sweet vermouth',3,'bottles'),(2,'Lapsang Souchong tea leaves',2,'oz')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Lapsang Souchong Infused Sweet Vermouth')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES (1,'Combine sweet vermouth and tea leaves in container.'),(2,'Shake to combine.'),(3,'Store for at least 3 hours.')) AS s(step_order,instruction);

-- Lapsang Souchong Infused Rye
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters) VALUES ('Lapsang Souchong Infused Rye', 3) RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'Mayor Pingree (orange label) rye',3,'bottles'),(2,'Lapsang Souchong tea leaves',2,'oz')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Lapsang Souchong Infused Rye')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES (1,'Combine rye and tea leaves in container.'),(2,'Shake to combine.'),(3,'Store for at least 3 hours.')) AS s(step_order,instruction);

-- Maple Simple Syrup
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Maple Simple Syrup', 2, 'Ratio 3:1 (Maple syrup:Water)') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'maple syrup',1.5,'L'),(2,'water',500,'ml')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Maple Simple Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine maple syrup and water in a stock pot.'),
    (2,'Bring to a boil.'),
    (3,'Stir to ensure maple syrup is dissolved.'),
    (4,'Turn off heat.'),
    (5,'Let cool for 30 minutes.'),
    (6,'Pour into container.'),
    (7,'Add 1.5oz vodka for preservation.')
  ) AS s(step_order,instruction);

-- Peanut Infused Whiskey (seasonal)
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Peanut Infused Whiskey', 6, 'Seasonal / specialty.') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'blanched unsalted peanuts',4,'lbs'),(2,'Mayor Pingree (red label) bourbon',6,'L')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Peanut Infused Whiskey')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES (1,'Combine peanuts and bourbon in container.'),(2,'Stir to combine.'),(3,'Store for 5–7 days.')) AS s(step_order,instruction);

-- Beet Rosemary Syrup (seasonal)
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Beet Rosemary Syrup', 3.5, 'Seasonal.') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'fresh beet juice',1250,'ml'),(2,'water',1150,'ml'),(3,'white/cane sugar',1.5,'kg'),(4,'fresh rosemary',8,'oz')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Beet Rosemary Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Use centrifugal juicer to extract juice from beets.'),
    (2,'Strain beet juice with a fine mesh strainer and set aside.'),
    (3,'Combine sugar and water in a stock pot.'),
    (4,'Bring to a boil.'),
    (5,'Stir to ensure sugar is dissolved.'),
    (6,'Turn off heat.'),
    (7,'Let cool for 30 minutes.'),
    (8,'Pour in beet juice.'),
    (9,'Add rosemary and strain into container.'),
    (10,'Add 1.5oz vodka for preservation.')
  ) AS s(step_order,instruction);

-- Cherry Vodka (seasonal)
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Cherry Vodka', 0.75, 'Ratio 1:2 (Maraschino cherry brine:Vodka). Seasonal.') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'maraschino cherry brine',250,'ml'),(2,'vodka',500,'ml')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Cherry Vodka')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine maraschino cherry brine and vodka into empty bottle.'),
    (2,'Shake to combine.'),
    (3,'Add pour spout or cap and place in refrigerator.')
  ) AS s(step_order,instruction);

-- Strawberry Gin Infusion (seasonal)
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Strawberry Gin Infusion', 5, 'Seasonal.') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'fresh strawberries',5,'pints'),(2,'Liberator gin',7.5,'L')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Strawberry Gin Infusion')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Cut leaves and tops off strawberries, and discard.'),
    (2,'Combine strawberries and gin in a large container.'),
    (3,'Stir to combine.'),
    (4,'Store for at least 3 days.')
  ) AS s(step_order,instruction);

-- Cucumber Vodka Infusion
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters) VALUES ('Cucumber Vodka Infusion', 5) RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'cucumbers',2,'whole'),(2,'vodka',5,'L')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Cucumber Vodka Infusion')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Peel and cut cucumbers into 1in quarter moons.'),
    (2,'Combine cucumbers and vodka in a large container.'),
    (3,'Stir to combine.'),
    (4,'Store for at least 3 days.')
  ) AS s(step_order,instruction);

-- Tre Pepper Vodka Infusion
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters) VALUES ('Tre Pepper Vodka Infusion', 5) RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'habanero peppers',2,'whole'),(2,'hungarian peppers',2,'whole'),(3,'sweet peppers',20,'whole'),(4,'vodka',5,'L')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Tre Pepper Vodka Infusion')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Cut in half and deseed all peppers.'),
    (2,'Combine peppers and vodka in a large container.'),
    (3,'Stir to combine.'),
    (4,'Store for at least 3 days.')
  ) AS s(step_order,instruction);

-- Bloody Mary Mix
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters) VALUES ('Bloody Mary Mix', 3.5) RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES
    (1,'tomato juice',64,'oz'),
    (2,'pickle brine',4,'oz'),
    (3,'worcestershire sauce',4,'oz'),
    (4,'lemon juice',4,'oz'),
    (5,'Valentina hot sauce',1.5,'oz'),
    (6,'garlic salt',2,'tablespoons'),
    (7,'celery salt',1.5,'tablespoons'),
    (8,'coarse black pepper',1.5,'tablespoons')
  ) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Bloody Mary Mix')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES (1,'Combine all ingredients in a large container.'),(2,'Shake to combine.')) AS s(step_order,instruction);

-- Coffee Liqueur
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters) VALUES ('Coffee Liqueur', 0.875) RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES
    (1,'brown sugar simple syrup',250,'ml'),
    (2,'cold brew',250,'ml'),
    (3,'vodka',250,'ml'),
    (4,'vanilla simple syrup',125,'ml'),
    (5,'instant espresso',3,'tablespoons')
  ) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Coffee Liqueur')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES (1,'Combine all ingredients in a large container.'),(2,'Shake well to combine.')) AS s(step_order,instruction);

-- Grenadine
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters) VALUES ('Grenadine', 1.5) RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'pomegranate juice',32,'oz'),(2,'white/cane sugar',4,'cups'),(3,'pomegranate molasses',4,'oz'),(4,'vodka',1.5,'oz')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Grenadine')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine pomegranate juice, sugar, and pomegranate molasses in a large container.'),
    (2,'Shake well to combine.'),
    (3,'Add vodka.'),
    (4,'Shake once more.')
  ) AS s(step_order,instruction);

-- Bourbon Creme
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters) VALUES ('Bourbon Creme', 1) RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES
    (1,'sweetened condensed milk',14,'oz'),
    (2,'Mayor Pingree (red label) bourbon',1.5,'cups'),
    (3,'half and half',1,'cups'),
    (4,'chocolate syrup',2,'tablespoons'),
    (5,'instant espresso',1,'teaspoon'),
    (6,'vanilla extract',1,'teaspoon')
  ) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Bourbon Creme')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES (1,'Combine all ingredients in a container.'),(2,'Shake well to combine.')) AS s(step_order,instruction);

-- Spicy Pickles (seasonal)
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Spicy Pickles', 20, 'Large batch. Seasonal / specialty.') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES
    (1,'pickles',1,'5-gallon bucket'),
    (2,'dried birdseye chilis',75,'g'),
    (3,'Sichuan peppercorns',7,'g'),
    (4,'habanero peppers',14,'whole'),
    (5,'dried chipotle peppers',2,'whole')
  ) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Spicy Pickles')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine dried birdseye chilis, Sichuan peppercorns, and chipotle peppers in a very large container.'),
    (2,'Cut habanero peppers in half and add to the container.'),
    (3,'Cut pickles into spears (halved lengthwise) and add to the container.'),
    (4,'Pour pickle brine into container.'),
    (5,'Gently stir to combine.'),
    (6,'Store in the refrigerator for at least 3 days.')
  ) AS s(step_order,instruction);

-- Blueberry Compote (seasonal)
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Blueberry Compote', 0.75, 'Seasonal.') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'blueberries',456,'g'),(2,'water',236,'ml'),(3,'vanilla extract',150,'ml'),(4,'sugar',320,'g'),(5,'lemons',2,'whole')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Blueberry Compote')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine blueberries, water, vanilla extract, and sugar in a stockpot.'),
    (2,'Bring to a boil.'),
    (3,'Add zest of lemons and simmer for 10 minutes.'),
    (4,'Let cool for 30 minutes.'),
    (5,'Pour into container.')
  ) AS s(step_order,instruction);

-- Strawberry Vanilla Simple Syrup
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Strawberry Vanilla Simple Syrup', 3, 'Ratio 1:1 (Water:Sugar)') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'fresh strawberries',3,'lbs'),(2,'white/cane sugar',1.5,'L'),(3,'water',1.5,'L'),(4,'vanilla extract',250,'ml')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Strawberry Vanilla Simple Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine strawberries, water, sugar, and vanilla extract in a stockpot.'),
    (2,'Bring to a boil.'),
    (3,'Simmer for 10 minutes.'),
    (4,'Let cool for 30 minutes.'),
    (5,'Strain into container.'),
    (6,'Add 1.5oz vodka for preservation.')
  ) AS s(step_order,instruction);

-- Pistachio Orgeat
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Pistachio Orgeat', 4, 'Ratio 1:1 (Water:Sugar)') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'pistachios',200,'g'),(2,'white/cane sugar',2,'kg'),(3,'water',2,'L')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Pistachio Orgeat')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Use blade grinder to grind pistachios into a powder.'),
    (2,'Combine water, ground pistachio, and sugar in a stockpot.'),
    (3,'Bring to a boil.'),
    (4,'Simmer for 10 minutes.'),
    (5,'Let cool for 30 minutes.'),
    (6,'Strain into container.'),
    (7,'Add 1.5oz vodka for preservation.')
  ) AS s(step_order,instruction);

-- Vanilla Simple Syrup
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Vanilla Simple Syrup', 4, 'Ratio 1:1 (Water:Sugar)') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'white/cane sugar',2,'kg'),(2,'water',2,'L'),(3,'vanilla extract',250,'ml')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Vanilla Simple Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine sugar, water, and vanilla extract in a stockpot.'),
    (2,'Bring to a boil.'),
    (3,'Let cool for 30 minutes.'),
    (4,'Pour into container.'),
    (5,'Add 1.5oz vodka for preservation.')
  ) AS s(step_order,instruction);

-- Raspberry Simple Syrup
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Raspberry Simple Syrup', 2.5, 'Ratio 1:1:1 (Water:Sugar:Raspberry Puree)') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'white/cane sugar',850,'g'),(2,'water',850,'ml'),(3,'raspberry puree',850,'ml')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Raspberry Simple Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Combine sugar, water, and raspberry puree in a stockpot.'),
    (2,'Bring to a boil.'),
    (3,'Simmer for 10 minutes.'),
    (4,'Let cool for 30 minutes.'),
    (5,'Pour into container.'),
    (6,'Add 1.5oz vodka for preservation.')
  ) AS s(step_order,instruction);

-- Hot Buttered Rum (seasonal)
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Hot Buttered Rum', 1, 'Seasonal. Rest 24 hours before serving.') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES
    (1,'unsalted butter',1,'lbs'),
    (2,'brown sugar',2,'cups'),
    (3,'cinnamon',1,'teaspoon'),
    (4,'nutmeg',0.5,'teaspoon'),
    (5,'allspice',0.5,'teaspoon'),
    (6,'rum',750,'ml')
  ) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Hot Buttered Rum')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Melt butter.'),
    (2,'While hot, combine brown sugar, cinnamon, nutmeg, and allspice with the butter.'),
    (3,'Pour in 750ml rum and whisk to combine.'),
    (4,'Cover and let rest for 24 hours.'),
    (5,'After 24 hours, skim off solidified fat.'),
    (6,'Strain into bottle.')
  ) AS s(step_order,instruction);

-- Bubblegum Simple Syrup
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters) VALUES ('Bubblegum Simple Syrup', 2.5) RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'water',2,'L'),(2,'white/cane sugar',6,'cups'),(3,'bubblegum',50,'pieces')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Bubblegum Simple Syrup')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Place bubblegum in cheesecloth and tie closed.'),
    (2,'Combine all ingredients in stock pot.'),
    (3,'Bring to a boil.'),
    (4,'Simmer for 30 minutes.'),
    (5,'Let cool for 30 minutes.'),
    (6,'Strain into container.')
  ) AS s(step_order,instruction);

-- Mint Tea
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters) VALUES ('Mint Tea', 2) RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'water',2,'L'),(2,'mint tea leaves',1,'cups')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Mint Tea')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Bring water to a boil in stock pot.'),
    (2,'Add mint tea leaves to water.'),
    (3,'Turn off heat.'),
    (4,'Let cool for 30 minutes.'),
    (5,'Strain into container.')
  ) AS s(step_order,instruction);

-- Passion Fruit Tea
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters) VALUES ('Passion Fruit Tea', 2) RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'water',2,'L'),(2,'dried passion fruit tea mix',1,'cups')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Passion Fruit Tea')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Bring water to a boil in stock pot.'),
    (2,'Add passion fruit tea mix to water.'),
    (3,'Turn off heat.'),
    (4,'Let cool for 30 minutes.'),
    (5,'Strain into container.')
  ) AS s(step_order,instruction);

-- Orange Oleo
WITH r AS (
  INSERT INTO recipes (name, base_yield_liters, notes) VALUES ('Orange Oleo', 0.25, 'Oleo saccharum — citrus oil expressed into sugar. Small yield.') RETURNING id
)
INSERT INTO recipe_ingredients (recipe_id, name, quantity, unit, sort_order)
  SELECT r.id, i.name, i.quantity, i.unit, i.sort_order FROM r,
  (VALUES (1,'oranges',4,'whole'),(2,'sugar',250,'g')) AS i(sort_order,name,quantity,unit);

WITH r AS (SELECT id FROM recipes WHERE name = 'Orange Oleo')
INSERT INTO recipe_steps (recipe_id, step_order, instruction)
  SELECT r.id, s.step_order, s.instruction FROM r,
  (VALUES
    (1,'Peel oranges.'),
    (2,'Combine sugar and orange peels in a mason jar.'),
    (3,'Shake vigorously.'),
    (4,'Store in refrigerator for at least 24 hours.')
  ) AS s(step_order,instruction);

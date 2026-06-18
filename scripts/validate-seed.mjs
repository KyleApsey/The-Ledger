/**
 * Validates seed/pars.json and seed/recipes.json against expected schema.
 * Run with: npm run seed:dry-run
 * Exits 0 on success, 1 on failure.
 */
import { readFileSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const root = resolve(__dirname, '..')

let errors = 0

function fail(msg) {
  console.error(`  FAIL: ${msg}`)
  errors++
}

function validateItem(item, index) {
  const prefix = `items[${index}]`
  if (typeof item.name !== 'string' || !item.name.trim())
    fail(`${prefix}.name must be a non-empty string`)
  if (!['syrups_infusions', 'juices', 'garnishes'].includes(item.category))
    fail(`${prefix}.category must be syrups_infusions | juices | garnishes (got: ${item.category})`)
  if (typeof item.par_level !== 'number' || item.par_level <= 0)
    fail(`${prefix}.par_level must be a positive number`)
  if (!['batches', 'containers', 'liters'].includes(item.stock_unit))
    fail(`${prefix}.stock_unit must be batches | containers | liters`)
  if (item.stock_unit === 'containers' && typeof item.container_volume_liters !== 'number')
    fail(`${prefix}.container_volume_liters required when stock_unit = containers`)
  if (typeof item.is_active !== 'boolean')
    fail(`${prefix}.is_active must be boolean`)
}

function validateRecipe(recipe, index) {
  const prefix = `recipes[${index}]`
  if (typeof recipe.name !== 'string' || !recipe.name.trim())
    fail(`${prefix}.name must be a non-empty string`)
  if (typeof recipe.base_yield_liters !== 'number' || recipe.base_yield_liters <= 0)
    fail(`${prefix}.base_yield_liters must be a positive number`)
  if (!Array.isArray(recipe.ingredients) || recipe.ingredients.length === 0)
    fail(`${prefix}.ingredients must be a non-empty array`)
  if (!Array.isArray(recipe.steps) || recipe.steps.length === 0)
    fail(`${prefix}.steps must be a non-empty array`)

  recipe.ingredients?.forEach((ing, i) => {
    const p = `${prefix}.ingredients[${i}]`
    if (typeof ing.name !== 'string' || !ing.name.trim()) fail(`${p}.name must be a non-empty string`)
    if (typeof ing.quantity !== 'number' || ing.quantity <= 0) fail(`${p}.quantity must be a positive number`)
    if (typeof ing.unit !== 'string' || !ing.unit.trim()) fail(`${p}.unit must be a non-empty string`)
  })

  recipe.steps?.forEach((step, i) => {
    if (typeof step !== 'string' || !step.trim())
      fail(`${prefix}.steps[${i}] must be a non-empty string`)
  })
}

// --- Validate pars.json ---
console.log('Validating seed/pars.json...')
try {
  const pars = JSON.parse(readFileSync(resolve(root, 'seed/pars.json'), 'utf8'))
  if (!Array.isArray(pars.items)) {
    fail('pars.json must have an "items" array')
  } else {
    pars.items.forEach(validateItem)
    console.log(`  OK: ${pars.items.length} items`)
  }
} catch (e) {
  fail(`Could not read/parse seed/pars.json: ${e.message}`)
}

// --- Validate recipes.json ---
console.log('Validating seed/recipes.json...')
try {
  const data = JSON.parse(readFileSync(resolve(root, 'seed/recipes.json'), 'utf8'))
  if (!Array.isArray(data.recipes)) {
    fail('recipes.json must have a "recipes" array')
  } else {
    data.recipes.forEach(validateRecipe)
    console.log(`  OK: ${data.recipes.length} recipes`)
  }
} catch (e) {
  fail(`Could not read/parse seed/recipes.json: ${e.message}`)
}

// --- Summary ---
if (errors > 0) {
  console.error(`\nSeed validation FAILED: ${errors} error(s). Fix before deploying.`)
  process.exit(1)
} else {
  console.log('\nSeed validation PASSED.')
}

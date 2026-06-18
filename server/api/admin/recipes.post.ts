export default defineEventHandler(async (event) => {
  await requireAdmin(event)
  const body = await readBody(event) ?? {}
  const { name, base_yield_liters, item_id = null, notes = null, ingredients = [], steps = [] } = body

  if (!name?.trim()) throw createError({ statusCode: 400, message: 'Name is required' })
  const yieldNum = parseFloat(base_yield_liters)
  if (isNaN(yieldNum) || yieldNum <= 0) throw createError({ statusCode: 400, message: 'Yield must be a positive number' })

  for (const ing of ingredients) {
    if (!ing.name?.trim()) throw createError({ statusCode: 400, message: 'Ingredient name is required' })
    const qty = parseFloat(ing.quantity)
    if (isNaN(qty) || qty <= 0) throw createError({ statusCode: 400, message: 'Ingredient quantity must be a positive number' })
    if (!ing.unit?.trim()) throw createError({ statusCode: 400, message: 'Ingredient unit is required' })
  }

  for (const step of steps) {
    if (!step.instruction?.trim()) throw createError({ statusCode: 400, message: 'Step instruction is required' })
  }

  const supabase = useServerSupabase()
  const { data, error } = await supabase.rpc('create_recipe', {
    p_name: name.trim(),
    p_base_yield_liters: yieldNum,
    p_item_id: item_id || null,
    p_notes: notes?.trim() || null,
    p_ingredients: ingredients.map((i: { name: string; quantity: string; unit: string }) => ({
      name: i.name.trim(),
      quantity: parseFloat(i.quantity),
      unit: i.unit.trim(),
    })),
    p_steps: steps.map((s: { instruction: string }) => ({
      instruction: s.instruction.trim(),
    })),
  })

  if (error) throw createError({ statusCode: 500, message: error.message })
  return { id: data }
})

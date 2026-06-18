export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  const supabase = useServerSupabase()

  const [{ data, error }, { data: lastBatch }] = await Promise.all([
    supabase
      .from('recipes')
      .select(`
        id, item_id, name, base_yield_liters, notes,
        recipe_ingredients (id, name, quantity, unit, sort_order),
        recipe_steps (id, instruction, step_order)
      `)
      .eq('id', id!)
      .is('archived_at', null)
      .single(),
    supabase
      .from('batches')
      .select('yield_liters, scale_factor, logged_at, staff(name)')
      .eq('recipe_id', id!)
      .order('logged_at', { ascending: false })
      .limit(1)
      .maybeSingle(),
  ])

  if (error || !data) throw createError({ statusCode: 404, message: 'Recipe not found' })

  data.recipe_ingredients.sort((a: any, b: any) => a.sort_order - b.sort_order)
  data.recipe_steps.sort((a: any, b: any) => a.step_order - b.step_order)

  return { ...data, last_batch: lastBatch ?? null }
})

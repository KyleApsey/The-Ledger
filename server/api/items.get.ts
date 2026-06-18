export default defineEventHandler(async (event) => {
  const supabase = useServerSupabase()
  const p_date = new Date().toLocaleDateString('en-CA', { timeZone: 'America/Detroit' })

  const { data, error } = await supabase.rpc('get_items_with_deficit', { p_date })

  if (error) throw createError({ statusCode: 500, message: error.message })

  return (data ?? []).map((item: any) => ({
    id: item.id,
    name: item.name,
    category: item.category,
    par_level: item.par_level,
    stock_unit: item.stock_unit,
    recipe: item.recipe_id
      ? { id: item.recipe_id, name: item.recipe_name, base_yield_liters: item.base_yield_liters }
      : null,
    batched_today: item.batched_today,
    stock_quantity: item.stock_quantity,
    deficit: Number(item.deficit),
    needs_prep: item.needs_prep,
  }))
})

export default defineEventHandler(async (event) => {
  const supabase = useServerSupabase()

  const { data, error } = await supabase
    .from('items')
    .select('id, name, category, par_level, stock_unit, container_volume_liters')
    .eq('is_active', true)
    .order('category')
    .order('name')

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})

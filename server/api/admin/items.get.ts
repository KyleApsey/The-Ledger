export default defineEventHandler(async (event) => {
  await requireAdmin(event)
  const supabase = useServerSupabase()
  const { data, error } = await supabase
    .from('items')
    .select('id, name, category, par_level, stock_unit, is_active')
    .order('category')
    .order('name')
  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})

export default defineEventHandler(async (event) => {
  await requireAdmin(event)
  const supabase = useServerSupabase()
  const { data, error } = await supabase
    .from('recipes')
    .select('id, item_id, name, base_yield_liters, archived_at')
    .order('name')
  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})

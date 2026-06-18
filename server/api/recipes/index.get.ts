export default defineEventHandler(async (event) => {
  const supabase = useServerSupabase()

  const { data, error } = await supabase
    .from('recipes')
    .select('id, item_id, name, base_yield_liters, items(category)')
    .is('archived_at', null)
    .order('name')

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})

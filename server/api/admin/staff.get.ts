export default defineEventHandler(async (event) => {
  await requireAdmin(event)
  const supabase = useServerSupabase()
  const { data, error } = await supabase.from('staff').select('id, name, is_admin, created_at').order('name')
  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})

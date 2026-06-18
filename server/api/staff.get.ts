// GET /api/staff — public, returns name + id only for the PIN picker.
// No authentication required; the PIN is the credential, not staff identity.
export default defineEventHandler(async () => {
  const supabase = useServerSupabase()
  const { data, error } = await supabase
    .from('staff')
    .select('id, name')
    .order('name')

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})

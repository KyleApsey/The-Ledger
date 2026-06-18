export default defineEventHandler(async (event) => {
  const supabase = useServerSupabase()
  const p_date = new Date().toLocaleDateString('en-CA', { timeZone: 'America/Detroit' })

  const { data, error } = await supabase
    .from('pars_check_sessions')
    .select('id, session_date, staff_id, created_at')
    .eq('session_date', p_date)
    .maybeSingle()

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data  // null if no session today
})

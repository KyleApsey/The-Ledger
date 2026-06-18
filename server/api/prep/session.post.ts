export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { entries } = body ?? {}

  if (!Array.isArray(entries)) {
    throw createError({ statusCode: 400, message: 'entries must be an array' })
  }

  const staff_id = event.context.auth.staff_id
  const supabase = useServerSupabase()

  const p_date = new Date().toLocaleDateString('en-CA', { timeZone: 'America/Detroit' })

  const { data, error } = await supabase.rpc('upsert_stock_check', {
    p_date,
    p_staff_id: staff_id,
    p_entries: entries,
  })

  if (error) throw createError({ statusCode: 500, message: error.message })
  return { session_id: data }
})

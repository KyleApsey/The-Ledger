const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export default defineEventHandler(async (event) => {
  const { item_id } = getQuery(event)

  if (!item_id) throw createError({ statusCode: 400, message: 'item_id required' })
  if (!UUID_RE.test(item_id as string)) throw createError({ statusCode: 400, message: 'Invalid item_id format' })

  const supabase = useServerSupabase()
  const today = new Date().toLocaleDateString('en-CA', { timeZone: 'America/Detroit' })

  const { data, error } = await supabase.rpc('undo_batch', {
    p_item_id: item_id as string,
    p_date: today,
  })

  if (error) throw createError({ statusCode: 500, message: error.message })

  const batched_today = Array.isArray(data) ? (data[0]?.batched_today ?? false) : false
  return { ok: true, batched_today }
})

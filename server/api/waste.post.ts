const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { id, item_id, quantity, unit, reason } = body ?? {}

  if (!id || !item_id || !quantity || !unit) {
    throw createError({ statusCode: 400, message: 'Missing required fields' })
  }
  if (!UUID_RE.test(id) || !UUID_RE.test(item_id)) {
    throw createError({ statusCode: 400, message: 'Invalid id format' })
  }
  if (quantity <= 0) {
    throw createError({ statusCode: 400, message: 'quantity must be > 0' })
  }

  const staff_id = event.context.auth.staff_id
  const supabase = useServerSupabase()

  const { error } = await supabase
    .from('waste_logs')
    .upsert(
      { id, item_id, staff_id, quantity, unit, reason: reason ?? null },
      { onConflict: 'id', ignoreDuplicates: true }
    )

  if (error) throw createError({ statusCode: 500, message: error.message })
  return { ok: true }
})

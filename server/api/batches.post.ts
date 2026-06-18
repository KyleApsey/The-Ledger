const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { id, item_id, yield_liters, recipe_id, scale_factor = 1, notes } = body ?? {}

  if (!id || !item_id || !yield_liters) throw createError({ statusCode: 400, message: 'Missing required fields' })
  if (!UUID_RE.test(id) || !UUID_RE.test(item_id)) throw createError({ statusCode: 400, message: 'Invalid id format' })
  if (recipe_id && !UUID_RE.test(recipe_id)) throw createError({ statusCode: 400, message: 'Invalid recipe_id format' })
  if (yield_liters <= 0) throw createError({ statusCode: 400, message: 'yield_liters must be > 0' })

  const staff_id = event.context.auth.staff_id
  const supabase = useServerSupabase()

  const { error } = await supabase
    .from('batches')
    .upsert(
      { id, item_id, staff_id, yield_liters, scale_factor, recipe_id: recipe_id ?? null, notes: notes ?? null },
      { onConflict: 'id', ignoreDuplicates: true },
    )

  if (error) throw createError({ statusCode: 500, message: error.message })
  return { ok: true }
})

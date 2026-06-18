export default defineEventHandler(async (event) => {
  await requireAdmin(event)
  const id = getRouterParam(event, 'id')
  const body = await readBody(event) ?? {}

  const allowed = ['is_active', 'par_level', 'name']
  const update = Object.fromEntries(Object.entries(body).filter(([k]) => allowed.includes(k)))
  if (Object.keys(update).length === 0) throw createError({ statusCode: 400, message: 'No valid fields' })

  const supabase = useServerSupabase()
  const { error } = await supabase.from('items').update(update).eq('id', id!)
  if (error) throw createError({ statusCode: 500, message: error.message })
  return { ok: true }
})

export default defineEventHandler(async (event) => {
  await requireAdmin(event)
  const id = getRouterParam(event, 'id')
  const { archive } = await readBody(event) ?? {}

  const supabase = useServerSupabase()
  const { error } = await supabase
    .from('recipes')
    .update({ archived_at: archive ? new Date().toISOString() : null })
    .eq('id', id!)

  if (error) throw createError({ statusCode: 500, message: error.message })
  return { ok: true }
})

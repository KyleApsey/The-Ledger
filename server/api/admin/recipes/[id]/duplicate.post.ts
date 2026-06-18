export default defineEventHandler(async (event) => {
  await requireAdmin(event)
  const id = getRouterParam(event, 'id')
  const supabase = useServerSupabase()

  const { data, error } = await supabase.rpc('duplicate_recipe', { p_recipe_id: id })
  if (error) throw createError({ statusCode: 500, message: error.message })
  return { id: data }
})

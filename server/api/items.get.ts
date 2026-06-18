export default defineEventHandler(async (event) => {
  const supabase = useServerSupabase()

  // "Today" window in UTC — Vercel functions run in UTC (us-east-1)
  const dayStart = new Date()
  dayStart.setUTCHours(0, 0, 0, 0)
  const dayEnd = new Date(dayStart.getTime() + 86_400_000)

  const [{ data: items, error }, { data: recipes }, { data: batches }] = await Promise.all([
    supabase.from('items').select('id, name, category, par_level, stock_unit').eq('is_active', true).order('name'),
    supabase.from('recipes').select('id, item_id, name, base_yield_liters').is('archived_at', null).not('item_id', 'is', null),
    supabase.from('batches').select('item_id').gte('logged_at', dayStart.toISOString()).lt('logged_at', dayEnd.toISOString()),
  ])

  if (error) throw createError({ statusCode: 500, message: error.message })

  const recipeByItem = Object.fromEntries((recipes ?? []).map(r => [r.item_id, r]))
  const batchedToday = new Set((batches ?? []).map(b => b.item_id))

  return (items ?? []).map(item => ({
    ...item,
    recipe: recipeByItem[item.id] ?? null,
    batched_today: batchedToday.has(item.id),
  }))
})

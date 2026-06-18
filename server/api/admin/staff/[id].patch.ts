import bcrypt from 'bcryptjs'

export default defineEventHandler(async (event) => {
  await requireAdmin(event)
  const id = getRouterParam(event, 'id')
  const { is_admin, pin } = await readBody(event) ?? {}

  const update: Record<string, unknown> = {}
  if (is_admin !== undefined) update.is_admin = Boolean(is_admin)
  if (pin !== undefined) {
    if (!/^\d{4}$/.test(pin)) throw createError({ statusCode: 400, message: 'PIN must be exactly 4 digits' })
    update.pin_hash = await bcrypt.hash(pin, 10)
  }

  if (Object.keys(update).length === 0) throw createError({ statusCode: 400, message: 'Nothing to update' })

  const supabase = useServerSupabase()
  const { error } = await supabase.from('staff').update(update).eq('id', id!)
  if (error) throw createError({ statusCode: 500, message: error.message })
  return { ok: true }
})

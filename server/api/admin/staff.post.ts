import bcrypt from 'bcryptjs'

export default defineEventHandler(async (event) => {
  await requireAdmin(event)
  const { name, pin, is_admin = false } = await readBody(event) ?? {}

  if (!name?.trim()) throw createError({ statusCode: 400, message: 'Name is required' })
  if (!/^\d{4}$/.test(pin)) throw createError({ statusCode: 400, message: 'PIN must be exactly 4 digits' })

  const pin_hash = await bcrypt.hash(pin, 10)
  const supabase = useServerSupabase()

  const { data, error } = await supabase
    .from('staff')
    .insert({ name: name.trim(), pin_hash, is_admin: Boolean(is_admin) })
    .select('id, name, is_admin')
    .single()

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})

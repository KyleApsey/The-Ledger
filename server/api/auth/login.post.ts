import bcrypt from 'bcryptjs'
import { SignJWT } from 'jose'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { staff_id, pin } = body ?? {}

  if (!staff_id || typeof pin !== 'string' || !/^\d{4}$/.test(pin)) {
    throw createError({ statusCode: 400, message: 'Invalid request' })
  }

  const supabase = useServerSupabase()
  const { data: staff } = await supabase
    .from('staff')
    .select('id, name, pin_hash, is_admin')
    .eq('id', staff_id)
    .single()

  // Use a constant-time comparison path regardless of whether staff exists
  const hashToCheck = staff?.pin_hash ?? '$2a$10$invalidhashpadding000000000000000000000000000000000000'
  const valid = staff ? await bcrypt.compare(pin, hashToCheck) : false

  if (!valid) {
    throw createError({ statusCode: 401, message: 'Invalid credentials' })
  }

  const config = useRuntimeConfig()
  const secret = new TextEncoder().encode(config.sessionSecret)

  const token = await new SignJWT({ is_admin: staff!.is_admin, name: staff!.name })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(staff!.id)
    .setIssuedAt()
    .setExpirationTime('2h')
    .sign(secret)

  return { token, staff_name: staff!.name, is_admin: staff!.is_admin }
})

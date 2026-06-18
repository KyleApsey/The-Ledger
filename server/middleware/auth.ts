import { jwtVerify } from 'jose'

export default defineEventHandler(async (event) => {
  const path = getRequestURL(event).pathname

  // Only guard API routes
  if (!path.startsWith('/api/')) return

  // Public routes — no token required
  if (path.startsWith('/api/auth/')) return
  if (path === '/api/staff') return

  const authorization = getHeader(event, 'authorization')
  if (!authorization?.startsWith('Bearer ')) {
    throw createError({ statusCode: 401, message: 'Unauthorized' })
  }

  const token = authorization.slice(7)
  const config = useRuntimeConfig()

  try {
    const secret = new TextEncoder().encode(config.sessionSecret)
    const { payload } = await jwtVerify(token, secret)
    event.context.auth = {
      staff_id: payload.sub as string,
      is_admin: payload.is_admin as boolean,
      name: payload.name as string,
    }
  } catch {
    throw createError({ statusCode: 401, message: 'Unauthorized' })
  }
})

// Client-side auth utilities — sessionStorage-backed, browser-only.
// Auto-imported by Nuxt in all Vue components and composables.

export function getToken() {
  if (process.server) return null
  return sessionStorage.getItem('auth_token')
}

export function getSession() {
  const token = getToken()
  if (!token) return null
  try {
    const payload = token.split('.')[1]
    return JSON.parse(atob(payload.replace(/-/g, '+').replace(/_/g, '/')))
  } catch {
    return null
  }
}

export function setSession(token) {
  sessionStorage.setItem('auth_token', token)
  sessionStorage.setItem('auth_last_active', Date.now().toString())
}

export function clearSession() {
  sessionStorage.removeItem('auth_token')
  sessionStorage.removeItem('auth_last_active')
}

export function isSessionValid() {
  const session = getSession()
  if (!session) return false
  if (Date.now() / 1000 > session.exp) {
    clearSession()
    return false
  }
  return true
}

export function updateActivity() {
  if (process.server) return
  sessionStorage.setItem('auth_last_active', Date.now().toString())
}

export function isIdleExpired() {
  if (process.server) return false
  const lastActive = sessionStorage.getItem('auth_last_active')
  if (!lastActive) return false
  return Date.now() - parseInt(lastActive) > 2 * 60 * 60 * 1000
}

export function getAuthHeaders() {
  const token = getToken()
  if (!token) return {}
  return { Authorization: `Bearer ${token}` }
}

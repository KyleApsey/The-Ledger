// Client-side route guard — redirects to /pin if session is missing or expired.
// Runs only in the browser (sessionStorage is not available on server).
export default defineNuxtRouteMiddleware(() => {
  if (process.server) return
  if (isIdleExpired()) {
    clearSession()
    return navigateTo('/pin')
  }
  if (!isSessionValid()) {
    return navigateTo('/pin')
  }
  updateActivity()
})

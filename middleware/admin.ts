// Client-side admin guard — redirects non-admin staff away from /manage/*.
// Server-side re-verification is handled by requireAdmin() in each admin route.
export default defineNuxtRouteMiddleware(() => {
  if (process.server) return
  const session = getSession()
  if (!session?.is_admin) return navigateTo('/checklist')
})

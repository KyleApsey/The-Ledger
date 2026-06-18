import type { H3Event } from 'h3'

export async function requireAdmin(event: H3Event) {
  const auth = event.context.auth
  if (!auth) throw createError({ statusCode: 403, message: 'Forbidden' })

  const supabase = useServerSupabase()
  const { data } = await supabase
    .from('staff')
    .select('is_admin')
    .eq('id', auth.staff_id)
    .single()

  if (!data?.is_admin) throw createError({ statusCode: 403, message: 'Forbidden' })
}

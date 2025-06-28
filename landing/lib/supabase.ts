import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export async function addToWaitlist(email: string, utmParams: Record<string, string>) {
  const { data, error } = await supabase
    .from('waiting_list')
    .insert([
      {
        email,
        utm_source: utmParams.utm_source || null,
        utm_medium: utmParams.utm_medium || null,
        utm_campaign: utmParams.utm_campaign || null,
        created_at: new Date().toISOString(),
      }
    ])
    .select()

  if (error) throw error
  return data
}
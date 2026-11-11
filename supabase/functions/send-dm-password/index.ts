import { createClient } from 'npm:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://the-chronicle.efomaofficial.workers.dev',
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Vary': 'Origin',
}

const json = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })

function makePassword(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(18))
  return btoa(String.fromCharCode(...bytes)).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '')
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405)

  const emailjsPrivateKey = Deno.env.get('EMAILJS_PRIVATE_KEY')
  const secretKeysRaw = Deno.env.get('SUPABASE_SECRET_KEYS')
  let serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if (!serviceKey && secretKeysRaw) {
    try {
      const keys = JSON.parse(secretKeysRaw)
      serviceKey = keys.default || Object.values(keys)[0] as string
    } catch { /* report missing configuration below */ }
  }
  if (!emailjsPrivateKey || !serviceKey) return json({ error: 'Service is not configured.' }, 503)

  const authHeader = req.headers.get('Authorization')
  if (!authHeader?.startsWith('Bearer ')) return json({ error: 'Sign in to request a password email.' }, 401)

  let body: { camp?: unknown }
  try { body = await req.json() } catch { return json({ error: 'Invalid request.' }, 400) }
  const camp = typeof body.camp === 'string' ? body.camp.trim() : ''
  if (!camp || camp.length > 128) return json({ error: 'Invalid request.' }, 400)

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  if (!supabaseUrl) return json({ error: 'Service is not configured.' }, 503)
  const admin = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } })

  // Check that this is a real authenticated project user (including enabled anonymous users).
  const token = authHeader.slice('Bearer '.length)
  const { data: authData, error: authError } = await admin.auth.getUser(token)
  if (authError || !authData.user) return json({ error: 'Sign in to request a password email.' }, 401)

  const { data: campaign, error: campaignError } = await admin
    .from('campaigns').select('id,name,dm_email').eq('id', camp).maybeSingle()
  if (campaignError || !campaign?.dm_email || !/^\S+@\S+\.\S+$/.test(campaign.dm_email)) {
    // Keep campaign existence and address private; don't disclose which lookup failed.
    return json({ error: 'Could not send the password email. Check the campaign backup email and try again.' }, 400)
  }

  const password = makePassword()
  const { data: rotation, error: rotateError } = await admin.rpc('rotate_campaign_dm_password_for_email', { camp, pw: password })
  if (rotateError || !rotation?.old_hash || !rotation?.new_hash) {
    return json({ error: 'Could not reset the campaign password. Please try again later.' }, 500)
  }

  try {
    const emailResponse = await fetch('https://api.emailjs.com/api/v1.0/email/send', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        service_id: 'service_xe6yass',
        template_id: 'template_9xvghzw',
        user_id: 'HoS5JIvwi-KInnOcC',
        accessToken: emailjsPrivateKey,
        template_params: {
          to_email: campaign.dm_email,
          campaign_name: campaign.name,
          new_password: password,
        },
      }),
    })
    if (!emailResponse.ok) throw new Error(`EmailJS returned ${emailResponse.status}`)
  } catch (error) {
    console.error('Campaign DM password email failed', error)
    const { error: rollbackError } = await admin.rpc('restore_campaign_dm_password_after_email_failure', {
      camp,
      expected_hash: rotation.new_hash,
      old_hash: rotation.old_hash,
    })
    if (rollbackError) console.error('Could not restore previous campaign password', rollbackError)
    return json({ error: 'The email could not be sent. The previous campaign password should still work; please try again later.' }, 502)
  }

  return json({ ok: true })
})

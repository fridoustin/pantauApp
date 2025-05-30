import { createClient } from 'npm:@supabase/supabase-js@2'
import { JWT } from 'npm:google-auth-library@9'
import serviceAccount from '../service-account.json' with { type: 'json' }

interface Notification {
  id: string
  title: string
  technician_id: string
}

interface WebhookPayload {
  type: 'INSERT'
  table: string
  record: Notification
  schema: 'public'
}

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {
  const payload: WebhookPayload = await req.json()

  const { data: workorderData, error: workorderError } = await supabase
    .from('workorder')
    .select('admin_id')
    .eq('id', payload.record.id)
    .single()

  if (workorderData && workorderData.admin_id) {
    const { data } = await supabase
      .from('technician')
      .select('fcm_token')
      .eq('technician_id', payload.record.technician_id)
      .single()

    const fcmToken = data!.fcm_token as string

    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    })

    await supabase
      .from('notification')
      .insert({
        'technician_id': payload.record.technician_id, 
        'title': 'Work Order Baru', 
        'message': `Anda menerima work order baru dengan judul ${payload.record.title}`,
        'wo_id': payload.record.id
      })

    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: fcmToken,
            notification: {
              title: `Work Order Baru`,
              body: `Anda menerima work order baru dengan judul ${payload.record.title}`,
            },
            android: {
              priority: "High",
            },
          },
        }),
      }
    )

    const resData = await res.json()
    if (res.status < 200 || 299 < res.status) {
      throw resData
    }

    return new Response(JSON.stringify(resData), {
      headers: { 'Content-Type': 'application/json' },
    })
  } else {
    return new Response(JSON.stringify({
      message: "Work order not found or wo_id is null",
      status: "skipped"
    }), {
      headers: { 'Content-Type': 'application/json' },
    })
  }
})

const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string
  privateKey: string
}): Promise<string> => {
  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err)
        return
      }
      resolve(tokens!.access_token!)
    })
  })
}
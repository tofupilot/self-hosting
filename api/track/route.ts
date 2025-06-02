import { NextRequest, NextResponse } from 'next/server';

const POSTHOG_API_URL = process.env.NEXT_PUBLIC_POSTHOG_HOST || 'https://app.posthog.com';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const {
      event,
      properties = {},
      distinct_id = 'deploy-script',
      is_exception = false,
      fingerprint,
    } = body;

    const apiKey = process.env.NEXT_PUBLIC_POSTHOG_KEY || process.env.POSTHOG_API_KEY;
    if (!apiKey) {
      return NextResponse.json({ error: 'PostHog API key missing' }, { status: 500 });
    }

    const payload: any = {
      api_key: apiKey,
      event: is_exception ? '$exception' : event,
      distinct_id,
      properties: { ...properties },
    };

    if (is_exception) {
      payload.properties['$exception_message'] = properties.message || 'Unknown error';
      payload.properties['$exception_type'] = properties.type || 'ShellScriptError';
      payload.properties['$exception_stack_trace'] = properties.stack || '';
      payload.properties['$exception_fingerprint'] = fingerprint || `error-${event}`;
    }

    const res = await fetch(`${POSTHOG_API_URL}/capture/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!res.ok) {
      const text = await res.text();
      return NextResponse.json({ error: 'PostHog error', detail: text }, { status: 502 });
    }

    return NextResponse.json({ success: true });
  } catch (err: any) {
    return NextResponse.json({ error: 'Internal error', detail: err.message }, { status: 500 });
  }
}

import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

/**
 * GET /api/releases/download
 *
 * Generates a signed Supabase Storage URL so the APK file can be
 * downloaded without exposing the service-role key to the browser.
 *
 * Query parameters:
 *   version - (optional) the APK version to download; defaults to latest.
 *
 * Environment variables required (server-side only, NOT prefixed with NEXT_PUBLIC_):
 *   SUPABASE_URL             – Supabase project URL
 *   SUPABASE_SERVICE_ROLE_KEY – Service-role key (never sent to browser)
 *   SUPABASE_APK_BUCKET      – Storage bucket name (defaults to "releases")
 */
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const version = searchParams.get('version') ?? process.env.NEXT_PUBLIC_APK_VERSION;

  if (!version) {
    return NextResponse.json({ error: 'Version is required.' }, { status: 400 });
  }

  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const bucket = process.env.SUPABASE_APK_BUCKET || 'releases';

  if (!supabaseUrl || !serviceRoleKey) {
    return NextResponse.json(
      { error: 'Supabase credentials not configured.' },
      { status: 503 }
    );
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  const objectPath = `takwa-v${version}.apk`;

  const { data, error } = await supabase.storage
    .from(bucket)
    .createSignedUrl(objectPath, 60 * 10, { download: true }); // 10-minute signed URL

  if (error || !data?.signedUrl) {
    console.error('[releases/download] Supabase error:', error);
    return NextResponse.json(
      { error: `Failed to generate download link: ${error?.message ?? 'Unknown error'}` },
      { status: 500 }
    );
  }

  return NextResponse.redirect(data.signedUrl);
}

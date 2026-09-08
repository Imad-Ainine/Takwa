import { NextResponse } from 'next/server';

/**
 * GET /api/releases/latest
 * Returns the current APK release metadata, reading from environment variables.
 * This avoids exposing service-role Supabase credentials on the client.
 */
export async function GET() {
  const apkUrl = process.env.NEXT_PUBLIC_APK_URL || null;
  const version = process.env.NEXT_PUBLIC_APK_VERSION || null;
  const size = process.env.NEXT_PUBLIC_APK_SIZE || null;
  const sha256 = process.env.NEXT_PUBLIC_APK_SHA256 || null;
  const sha1 = process.env.NEXT_PUBLIC_APK_SHA1 || null;
  const releasedAt = process.env.NEXT_PUBLIC_APK_RELEASED_AT || null;

  if (!apkUrl || !version) {
    return NextResponse.json(
      { error: 'No APK release configured yet.' },
      { status: 404 }
    );
  }

  return NextResponse.json({
    version,
    apkUrl,
    size,
    sha256,
    sha1,
    releasedAt,
  });
}

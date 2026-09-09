import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

/**
 * GET /api/releases/download?version=1.0.1
 *
 * Redirects to the GitHub Releases download URL for the requested APK version.
 * If no version is supplied it reads the latest version from the Supabase manifest.
 *
 * Environment variables required (server-side only):
 *   SUPABASE_URL              – Supabase project URL
 *   SUPABASE_SERVICE_ROLE_KEY – Service-role key (never sent to the browser)
 *   SUPABASE_APK_BUCKET       – Storage bucket name (defaults to "apk-releases")
 *   GITHUB_REPO               – "owner/repo" for building GitHub Release URLs
 *                               (defaults to "Imad-Ainine/Takkwa")
 */

interface ReleaseManifest {
  version: string;
  apkUrl: string;
}

async function getManifest(supabaseUrl: string, serviceRoleKey: string, bucket: string): Promise<ReleaseManifest | null> {
  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  const { data, error } = await supabase.storage.from(bucket).download('manifest.json');
  if (error || !data) return null;

  try {
    return JSON.parse(await data.text()) as ReleaseManifest;
  } catch {
    return null;
  }
}

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);

  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const bucket = process.env.SUPABASE_APK_BUCKET || 'apk-releases';
  const githubRepo = process.env.GITHUB_REPO || 'Imad-Ainine/Takkwa';

  let version = searchParams.get('version');

  if (supabaseUrl && serviceRoleKey) {
    if (!version) {
      const manifest = await getManifest(supabaseUrl, serviceRoleKey, bucket);
      version = manifest?.version ?? process.env.NEXT_PUBLIC_APK_VERSION ?? '1.0.0';
    }
  } else {
    // If Supabase credentials are not set on Vercel, fallback to env var or default version
    version = version || process.env.NEXT_PUBLIC_APK_VERSION || '1.0.0';
  }

  if (!version) {
    return NextResponse.json({ error: 'No APK version available.' }, { status: 404 });
  }

  // Build the GitHub Releases direct-download URL
  const downloadUrl = `https://github.com/${githubRepo}/releases/download/v${version}/takwa-v${version}.apk`;

  // Redirect directly to GitHub — no signed URL needed since GitHub Releases are public
  return NextResponse.redirect(downloadUrl, { status: 302 });
}

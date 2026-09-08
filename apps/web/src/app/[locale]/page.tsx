import { getTranslations } from 'next-intl/server';
import { createClient } from '@supabase/supabase-js';
import LandingPage from '@/components/landing/LandingPage';

export const dynamic = 'force-dynamic';

interface ReleaseManifest {
  version: string;
  apkUrl: string;
  size: string;
  sizeBytes?: number;
  sha256: string;
  sha1: string;
  releasedAt: string;
}

async function getLatestReleaseManifest(): Promise<Partial<ReleaseManifest>> {
  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const bucket = process.env.SUPABASE_APK_BUCKET || 'apk-releases';

  if (!supabaseUrl || !serviceRoleKey) return {};

  try {
    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false },
    });

    const { data, error } = await supabase.storage
      .from(bucket)
      .download('manifest.json');

    if (!error && data) {
      const text = await data.text();
      return JSON.parse(text) as ReleaseManifest;
    }
  } catch (err) {
    console.warn('[Home] Failed to load manifest from Supabase:', err);
  }

  return {};
}

/**
 * Landing page — Server Component.
 * Dynamically queries the latest release manifest from Supabase Storage
 * so any new release (auto-bumped or published) is immediately reflected
 * without requiring a Vercel redeploy.
 */
export default async function Home() {
  await getTranslations('HomePage'); // preload translations on server

  const manifest = await getLatestReleaseManifest();

  const apkUrl = manifest.apkUrl || process.env.NEXT_PUBLIC_APK_URL || '/api/releases/download';
  const apkVersion = manifest.version || process.env.NEXT_PUBLIC_APK_VERSION || '1.0.0';
  const apkSize = manifest.size || process.env.NEXT_PUBLIC_APK_SIZE || '';
  const sha1 = manifest.sha1 || process.env.NEXT_PUBLIC_APK_SHA1 || '';
  const sha256 = manifest.sha256 || process.env.NEXT_PUBLIC_APK_SHA256 || '';

  return (
    <LandingPage
      apkUrl={apkUrl}
      apkVersion={apkVersion}
      apkSize={apkSize}
      sha256={sha256}
      sha1={sha1}
    />
  );
}

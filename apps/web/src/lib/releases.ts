import { createClient } from '@supabase/supabase-js';

export interface ReleaseInfo {
  version: string;
  apkUrl: string;
  size: string;
  sha256: string;
  sha1: string;
  downloadFilename: string;
}

/**
 * Automatically resolves the latest released APK metadata.
 * 1. Checks GitHub Releases API for the latest published release (auto-updates after CI build).
 *    NOTE: For private repos, set GITHUB_TOKEN as a server-side env var on Vercel.
 * 2. Falls back to Supabase Storage manifest.json if configured.
 * 3. Falls back to NEXT_PUBLIC_APK_* environment variables.
 */
export async function getLatestRelease(): Promise<ReleaseInfo> {
  const defaultVersion = process.env.NEXT_PUBLIC_APK_VERSION || '1.0.5';
  const defaultUrl = process.env.NEXT_PUBLIC_APK_URL || `/api/releases/download?version=${defaultVersion}`;
  const defaultSize = process.env.NEXT_PUBLIC_APK_SIZE || '';
  const defaultSha256 = process.env.NEXT_PUBLIC_APK_SHA256 || '';
  const defaultSha1 = process.env.NEXT_PUBLIC_APK_SHA1 || '';

  // 1. Try GitHub Releases API
  // For private repos this REQUIRES a server-side GITHUB_TOKEN env var on Vercel.
  try {
    const repo = process.env.GITHUB_REPO || 'Imad-Ainine/Takwa';
    const githubToken = process.env.GITHUB_TOKEN; // server-side only, never NEXT_PUBLIC_

    const headers: Record<string, string> = {
      Accept: 'application/vnd.github.v3+json',
      'User-Agent': 'Takwa-App',
    };
    if (githubToken) {
      headers['Authorization'] = `Bearer ${githubToken}`;
    }

    const res = await fetch(`https://api.github.com/repos/${repo}/releases/latest`, {
      next: { revalidate: 60 },
      headers,
    });

    if (res.ok) {
      const release = await res.json();
      const version = (release.tag_name || '').replace(/^v/, '');
      const apkAsset = release.assets?.find((a: { name?: string }) => a.name?.endsWith('.apk'));

      if (version && apkAsset) {
        const sizeMb = (apkAsset.size / (1024 * 1024)).toFixed(2) + ' MB';
        const sha256Match = release.body?.match(/SHA-256\s*\|\s*`([a-fA-F0-9]+)`/);
        const sha1Match = release.body?.match(/SHA-1\s*\|\s*`([a-fA-F0-9]+)`/);

        return {
          version,
          apkUrl: apkAsset.browser_download_url,
          size: sizeMb,
          sha256: sha256Match ? sha256Match[1] : defaultSha256,
          sha1: sha1Match ? sha1Match[1] : defaultSha1,
          downloadFilename: apkAsset.name || `takwa-v${version}.apk`,
        };
      }
    }
  } catch (err) {
    console.warn('[getLatestRelease] Error checking GitHub Releases API:', err);
  }

  // 2. Try Supabase Storage manifest fallback
  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const bucket = process.env.SUPABASE_APK_BUCKET || 'apk-releases';

  if (supabaseUrl && serviceRoleKey) {
    try {
      const supabase = createClient(supabaseUrl, serviceRoleKey, {
        auth: { persistSession: false },
      });

      const { data, error } = await supabase.storage
        .from(bucket)
        .download('manifest.json');

      if (!error && data) {
        const manifest = JSON.parse(await data.text());
        const version = manifest.version || defaultVersion;
        return {
          version,
          apkUrl: manifest.apkUrl || defaultUrl,
          size: manifest.size || defaultSize,
          sha256: manifest.sha256 || defaultSha256,
          sha1: manifest.sha1 || defaultSha1,
          downloadFilename: `takwa-v${version}.apk`,
        };
      }
    } catch (err) {
      console.warn('[getLatestRelease] Error checking Supabase storage:', err);
    }
  }

  return {
    version: defaultVersion,
    apkUrl: defaultUrl,
    size: defaultSize,
    sha256: defaultSha256,
    sha1: defaultSha1,
    downloadFilename: `takwa-v${defaultVersion}.apk`,
  };
}

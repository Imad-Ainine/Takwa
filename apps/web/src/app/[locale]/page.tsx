import { getTranslations } from 'next-intl/server';
import LandingPage from '@/components/landing/LandingPage';

/**
 * Landing page — Server Component.
 * Reads APK distribution env vars and passes them to the client-side
 * LandingPage. No service-role keys here; only NEXT_PUBLIC_* vars are used.
 */
export default async function Home() {
  await getTranslations('HomePage'); // preload translations on server

  const apkUrl = process.env.NEXT_PUBLIC_APK_URL || '';
  const apkVersion = process.env.NEXT_PUBLIC_APK_VERSION || '1.0.0';
  const apkSize = process.env.NEXT_PUBLIC_APK_SIZE || '';
  const sha1 = process.env.NEXT_PUBLIC_APK_SHA1 || '';
  const sha256 = process.env.NEXT_PUBLIC_APK_SHA256 || '';

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

import React from 'react';
import dynamic from 'next/dynamic';
import HeroSection from '@/components/landing/HeroSection';

// Dynamically code-split below-the-fold sections while preserving full SSR for SEO & zero CLS
const FeaturesSection = dynamic(
  () => import('@/components/landing/FeaturesSection'),
  { ssr: true }
);

const SpiritualQuoteBanner = dynamic(
  () => import('@/components/landing/SpiritualQuoteBanner'),
  { ssr: true }
);

const ScreenshotsShowcase = dynamic(
  () => import('@/components/landing/ScreenshotsShowcase'),
  { ssr: true }
);

const DownloadSection = dynamic(
  () => import('@/components/landing/DownloadSection'),
  { ssr: true }
);

interface HomeProps {
  apkUrl?: string;
  apkVersion?: string;
  apkSize?: string;
  sha256?: string;
  sha1?: string;
}

export default function LandingPage({
  apkUrl,
  apkVersion,
  apkSize,
  sha256,
  sha1,
}: HomeProps) {
  return (
    <main id="main-content">
      <HeroSection
        apkUrl={apkUrl}
        apkVersion={apkVersion}
        apkSize={apkSize}
      />
      <FeaturesSection />
      <SpiritualQuoteBanner />
      <ScreenshotsShowcase />
      <DownloadSection
        apkUrl={apkUrl}
        apkVersion={apkVersion}
        apkSize={apkSize}
        sha256={sha256}
        sha1={sha1}
      />
    </main>
  );
}

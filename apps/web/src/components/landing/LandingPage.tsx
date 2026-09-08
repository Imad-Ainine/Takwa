'use client';

import React from 'react';
import dynamic from 'next/dynamic';
import HeroSection from '@/components/landing/HeroSection';
import FeaturesSection from '@/components/landing/FeaturesSection';
import SpiritualQuoteBanner from '@/components/landing/SpiritualQuoteBanner';

// Dynamically import heavy components to improve initial load
const ScreenshotsShowcase = dynamic(
  () => import('@/components/landing/ScreenshotsShowcase'),
  { ssr: false }
);
const DownloadSection = dynamic(
  () => import('@/components/landing/DownloadSection'),
  { ssr: false }
);

interface HomeProps {
  apkUrl?: string;
  apkVersion?: string;
  apkSize?: string;
  sha256?: string;
  sha1?: string;
}

export default function Home({
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

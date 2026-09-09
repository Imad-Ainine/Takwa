'use client';

import React, { useEffect, useRef, useState, useCallback } from 'react';
import { useTranslations } from 'next-intl';


interface DownloadSectionProps {
  apkUrl?: string;
  apkVersion?: string;
  apkSize?: string;
  sha256?: string;
  sha1?: string;
}


const PLATFORMS = [
  { key: 'android', nameKey: 'downloadHub.platforms.android.name', statusKey: 'downloadHub.platforms.android.status', active: true, icon: '🤖' },
  { key: 'play', nameKey: 'downloadHub.platforms.play.name', statusKey: 'downloadHub.platforms.play.status', active: false, icon: '🏪' },
  { key: 'ios', nameKey: 'downloadHub.platforms.ios.name', statusKey: 'downloadHub.platforms.ios.status', active: false, icon: '🍎' },
  { key: 'web', nameKey: 'downloadHub.platforms.web.name', statusKey: 'downloadHub.platforms.web.status', active: true, icon: '🌐' },
] as const;

// Simple SVG QR Code component (pattern-based placeholder that looks like a real QR)
function QRCodeDisplay({ url }: { url: string }) {
  const [qrDataUrl, setQrDataUrl] = useState<string | null>(null);

  useEffect(() => {
    if (!url) return;
    // Generate QR code using the qrcode library
    import('qrcode').then((QRCode) => {
      QRCode.toDataURL(url || 'https://takwa-app.com/#download', {
        width: 220,
        margin: 2,
        color: {
          dark: '#c8a96e',
          light: '#04011e',
        },
        errorCorrectionLevel: 'H',
      }).then((dataUrl) => {
        setQrDataUrl(dataUrl);
      }).catch(() => {
        // Fallback - generate with white on dark
        QRCode.toDataURL(url || 'https://takwa-app.com/#download', {
          width: 220,
          margin: 2,
        }).then(setQrDataUrl);
      });
    });
  }, [url]);

  if (!qrDataUrl) {
    return (
      <div className="qr-placeholder">
        <div className="qr-loading-grid">
          {Array.from({ length: 81 }).map((_, i) => {
            const isDark = [0, 1, 2, 8, 9, 10, 18, 19, 20, 24, 28, 32, 36, 40, 48, 54, 63, 64, 65, 72, 73, 74].includes(i);
            return <div key={i} className={`qr-cell ${isDark ? 'qr-cell-dark' : ''}`} />;
          })}
        </div>
      </div>
    );
  }

  return (
    <div className="qr-image-wrap">
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img src={qrDataUrl} alt="Scan to download Takwa APK" className="qr-img" width={200} height={200} />
    </div>
  );
}

export default function DownloadSection({
  apkUrl = '',
  apkVersion = '1.0.0',
  apkSize = '',
  sha256 = '',
  sha1 = '',
}: DownloadSectionProps) {
  const t = useTranslations('HomePage');
  const sectionRef = useRef<HTMLElement>(null);
  const [copiedSha, setCopiedSha] = useState<'sha256' | 'sha1' | null>(null);

  useEffect(() => {
    const el = sectionRef.current;
    if (!el) return;
    const pref = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (pref) {
      el.classList.add('download-visible');
      return;
    }
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          el.classList.add('download-visible');
          observer.disconnect();
        }
      },
      { threshold: 0.08, rootMargin: '0px 0px -50px 0px' }
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  const copyHash = useCallback(async (type: 'sha256' | 'sha1', value: string) => {
    try {
      await navigator.clipboard.writeText(value);
      setCopiedSha(type);
      setTimeout(() => setCopiedSha(null), 2500);
    } catch { /* clipboard access denied */ }
  }, []);

  const downloadUrl = apkUrl || '#';
  const downloadFilename = `takwa-v${apkVersion}.apk`;

  return (
    <section ref={sectionRef} className="section download-section" id="download">
      <div className="container">
        {/* Section Header */}
        <div className="download-header">
          <div className="trust-badge" style={{ marginBottom: '20px' }}>
            <span className="dot" />
            {t('downloadHub.tag')}
          </div>
          <h2 className="gold-text download-section-title">{t('downloadHub.title')}</h2>
          <p className="download-section-subtitle">{t('downloadHub.subtitle')}</p>
        </div>

        <div className="download-layout">
          {/* === Main Download Card === */}
          <div className="mihrab-card download-main-card">
            {/* Card Glow Ornament */}
            <div className="download-card-glow" aria-hidden="true" />

            {/* Top Section: QR + Info */}
            <div className="dl-top">
              {/* QR Code Block */}
              <div className="qr-block">
                <QRCodeDisplay url={apkUrl || 'https://takwa-app.com/#download'} />
                <p className="qr-hint">{t('downloadHub.qrTitle')}</p>
                <p className="qr-subhint">{t('downloadHub.qrSubtitle')}</p>
              </div>

              {/* Meta Information */}
              <div className="dl-info">
                <div className="dl-android-badge">
                  <span className="android-logo" aria-hidden="true">🤖</span>
                  <div>
                    <span className="android-name">{t('downloadHub.badgeAndroid')}</span>
                    {apkSize && (
                      <span className="android-size">
                        {t('downloadHub.badgeSize', { size: apkSize })}
                      </span>
                    )}
                  </div>
                </div>

                {/* Primary Download Button */}
                {apkUrl ? (
                  <a
                    href={downloadUrl}
                    download={downloadFilename}
                    className="btn-primary dl-btn"
                    id="main-download-apk-btn"
                    aria-label={`Download Takwa APK version ${apkVersion}`}
                  >
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                      stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                      <polyline points="7 10 12 15 17 10" />
                      <line x1="12" y1="15" x2="12" y2="3" />
                    </svg>
                    {t('downloadHub.ctaButton', { version: apkVersion })}
                  </a>
                ) : (
                  <div className="dl-btn-unavailable" id="download-unavailable-msg">
                    <span>⏳</span>
                    <span>Coming Soon — Early Access</span>
                  </div>
                )}

                {/* Checksum Verification */}
                {(sha256 || sha1) && (
                  <div className="checksum-block">
                    {sha256 && (
                      <div className="checksum-row">
                        <span className="checksum-label">{t('downloadHub.shaTitle')}</span>
                        <div className="checksum-value-wrap">
                          <code className="checksum-code">{sha256.slice(0, 16)}…</code>
                          <button
                            type="button"
                            className="copy-btn"
                            onClick={() => copyHash('sha256', sha256)}
                            aria-label="Copy SHA-256 hash"
                            title={t('downloadHub.copy')}
                          >
                            {copiedSha === 'sha256' ? '✓' : '⎘'}
                          </button>
                        </div>
                        {copiedSha === 'sha256' && (
                          <span className="copied-msg">{t('downloadHub.copied')}</span>
                        )}
                      </div>
                    )}
                    {sha1 && (
                      <div className="checksum-row">
                        <span className="checksum-label">{t('downloadHub.sha1Title')}</span>
                        <div className="checksum-value-wrap">
                          <code className="checksum-code">{sha1.slice(0, 16)}…</code>
                          <button
                            type="button"
                            className="copy-btn"
                            onClick={() => copyHash('sha1', sha1)}
                            aria-label="Copy SHA-1 hash"
                            title={t('downloadHub.copy')}
                          >
                            {copiedSha === 'sha1' ? '✓' : '⎘'}
                          </button>
                        </div>
                        {copiedSha === 'sha1' && (
                          <span className="copied-msg">{t('downloadHub.copied')}</span>
                        )}
                      </div>
                    )}
                  </div>
                )}

                {/* Security Trust Line */}
                <p className="security-trust-line">
                  🔒 {t('downloadHub.securityTrust')}
                </p>
              </div>
            </div>

            {/* Install Guide Steps */}
            <div className="install-guide">
              <h3 className="guide-title">{t('downloadHub.installGuide.title')}</h3>
              <div className="guide-steps">
                {(['step1', 'step2', 'step3'] as const).map((step, i) => (
                  <div className="guide-step" key={step}>
                    <div className="step-number">{i + 1}</div>
                    <div>
                      <strong className="step-title">{t(`downloadHub.installGuide.${step}.title`)}</strong>
                      <p className="step-desc">{t(`downloadHub.installGuide.${step}.desc`)}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* === Side Panel: Platform Status === */}
          <div className="download-side-panel">
            <h3 className="side-title">{t('downloadHub.sideTitle')}</h3>
            <div className="platforms-list">
              {PLATFORMS.map((platform) => (
                <div key={platform.key} className={`platform-item ${platform.active ? 'platform-active' : 'platform-coming'}`}>
                  <span className="platform-icon">{platform.icon}</span>
                  <div className="platform-info">
                    <span className="platform-name">{t(platform.nameKey)}</span>
                    <span className={`platform-status ${platform.active ? 'status-active' : 'status-pending'}`}>
                      {platform.active ? '● ' : '○ '}
                      {t(platform.statusKey)}
                    </span>
                  </div>
                </div>
              ))}
            </div>

            {/* Privacy / Trust Card */}
            <div className="privacy-card">
              <div className="privacy-icon">🛡️</div>
              <div>
                <h4 className="privacy-title">{t('downloadHub.privacyTitle')}</h4>
                <p className="privacy-body">
                  {t('downloadHub.privacyBody')}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

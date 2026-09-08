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

      <style jsx>{`
        .download-section {
          background: linear-gradient(180deg, #04011e 0%, #070340 60%, #04011e 100%);
        }
        .download-header {
          text-align: center;
          max-width: 680px;
          margin: 0 auto 56px;
          opacity: 0;
          transform: translateY(28px);
          transition: opacity 0.75s ease, transform 0.75s ease;
        }
        .download-section-title {
          font-size: clamp(1.9rem, 3.5vw, 2.9rem);
          line-height: 1.2;
          margin-bottom: 16px;
        }
        .download-section-subtitle {
          font-size: 1.08rem;
          color: var(--text-secondary);
          line-height: 1.65;
        }

        /* Layout */
        .download-layout {
          display: grid;
          grid-template-columns: 1fr 340px;
          gap: 28px;
          align-items: start;
        }

        /* Main Card */
        .download-main-card {
          padding: 36px;
          opacity: 0;
          transform: translateX(-30px);
          transition: opacity 0.75s ease, transform 0.75s ease;
        }
        .download-side-panel {
          opacity: 0;
          transform: translateX(30px);
          transition: opacity 0.75s ease, transform 0.75s ease;
        }
        .download-visible .download-header {
          opacity: 1;
          transform: translateY(0);
        }
        .download-visible .download-main-card {
          opacity: 1;
          transform: translateX(0);
        }
        .download-visible .download-side-panel {
          opacity: 1;
          transform: translateX(0);
        }
        .download-card-glow {
          position: absolute;
          top: 0; left: 0; right: 0;
          height: 160px;
          background: radial-gradient(ellipse at 50% 0%, rgba(229, 185, 88, 0.14) 0%, transparent 70%);
          pointer-events: none;
        }
        .dl-top {
          display: flex;
          gap: 40px;
          align-items: flex-start;
          margin-bottom: 36px;
        }

        /* QR Block */
        .qr-block {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 12px;
          flex-shrink: 0;
        }
        .qr-image-wrap, .qr-placeholder {
          background: #04011e;
          border: 2px solid rgba(200, 169, 110, 0.3);
          border-radius: 16px;
          padding: 12px;
          box-shadow: 0 0 20px rgba(229, 185, 88, 0.12);
        }
        .qr-img {
          display: block;
          border-radius: 8px;
        }
        .qr-placeholder {
          width: 200px;
          height: 200px;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .qr-loading-grid {
          display: grid;
          grid-template-columns: repeat(9, 1fr);
          gap: 2px;
          width: 162px;
          height: 162px;
        }
        .qr-cell { background: rgba(200,169,110,0.08); border-radius: 2px; }
        .qr-cell-dark { background: rgba(200,169,110,0.6); }
        .qr-hint {
          font-size: 0.85rem;
          font-weight: 700;
          color: var(--gold-light);
          text-align: center;
          max-width: 180px;
        }
        .qr-subhint {
          font-size: 0.75rem;
          color: var(--text-muted);
          text-align: center;
          max-width: 180px;
          line-height: 1.5;
        }

        /* DL Info */
        .dl-info {
          display: flex;
          flex-direction: column;
          gap: 20px;
          flex: 1;
        }
        .dl-android-badge {
          display: flex;
          align-items: center;
          gap: 14px;
          padding: 14px 18px;
          background: rgba(255,255,255,0.03);
          border: 1px solid rgba(200, 169, 110, 0.2);
          border-radius: var(--radius-md);
        }
        .android-logo { font-size: 2rem; }
        .android-name {
          display: block;
          font-size: 0.9rem;
          font-weight: 700;
          color: var(--text-primary);
        }
        .android-size {
          display: block;
          font-size: 0.8rem;
          color: var(--text-secondary);
          margin-top: 2px;
        }
        .dl-btn {
          font-size: 1rem;
          padding: 16px 28px;
        }
        .dl-btn-unavailable {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 14px 24px;
          background: rgba(255,255,255,0.02);
          border: 1px dashed rgba(255,255,255,0.15);
          border-radius: var(--radius-md);
          color: var(--text-muted);
          font-size: 0.9rem;
        }

        /* Checksums */
        .checksum-block {
          display: flex;
          flex-direction: column;
          gap: 10px;
        }
        .checksum-row {
          display: flex;
          flex-direction: column;
          gap: 5px;
        }
        .checksum-label {
          font-size: 0.72rem;
          font-weight: 700;
          color: var(--text-secondary);
          text-transform: uppercase;
          letter-spacing: 0.08em;
        }
        .checksum-value-wrap {
          display: flex;
          align-items: center;
          gap: 8px;
          background: rgba(0,0,0,0.3);
          padding: 6px 10px;
          border-radius: 8px;
          border: 1px solid rgba(255,255,255,0.07);
          direction: ltr;
        }
        .checksum-code {
          font-size: 0.72rem;
          font-family: 'Courier New', monospace;
          color: var(--gold-light);
          flex: 1;
          word-break: break-all;
          direction: ltr;
          text-align: left; 
        }
        .copy-btn {
          background: rgba(229,185,88,0.1);
          border: 1px solid rgba(229,185,88,0.25);
          color: var(--gold-vibrant);
          padding: 4px 10px;
          border-radius: 6px;
          font-size: 0.82rem;
          cursor: pointer;
          flex-shrink: 0;
          transition: all 0.2s ease;
        }
        .copy-btn:hover {
          background: rgba(229,185,88,0.2);
        }
        .copied-msg {
          font-size: 0.72rem;
          color: var(--success);
          margin-top: 2px;
        }
        .security-trust-line {
          font-size: 0.8rem;
          color: var(--text-muted);
          background: rgba(16, 185, 129, 0.06);
          border: 1px solid rgba(16, 185, 129, 0.18);
          border-radius: 8px;
          padding: 10px 14px;
          line-height: 1.5;
        }

        /* Install Guide */
        .install-guide {
          border-top: 1px solid rgba(200,169,110,0.15);
          padding-top: 28px;
        }
        .guide-title {
          font-size: 0.95rem;
          font-weight: 700;
          color: var(--gold-light);
          margin-bottom: 20px;
        }
        .guide-steps {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 16px;
        }
        .guide-step {
          display: flex;
          flex-direction: column;
          gap: 12px;
        }
        .step-number {
          width: 36px;
          height: 36px;
          border-radius: 50%;
          background: linear-gradient(135deg, rgba(229,185,88,0.2), rgba(200,169,110,0.1));
          border: 1px solid rgba(229,185,88,0.35);
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: 800;
          font-size: 1rem;
          color: var(--gold-vibrant);
        }
        .step-title {
          display: block;
          font-size: 0.88rem;
          font-weight: 700;
          color: var(--text-primary);
          margin-bottom: 4px;
        }
        .step-desc {
          font-size: 0.8rem;
          color: var(--text-secondary);
          line-height: 1.55;
        }

        /* Side Panel */
        .download-side-panel {
          display: flex;
          flex-direction: column;
          gap: 20px;
        }
        .side-title {
          font-size: 1rem;
          font-weight: 700;
          color: var(--text-primary);
          margin-bottom: 4px;
        }
        .platforms-list {
          background: var(--card);
          border: 1px solid var(--card-border);
          border-radius: var(--radius-lg);
          overflow: hidden;
        }
        .platform-item {
          display: flex;
          align-items: center;
          gap: 14px;
          padding: 16px 18px;
          border-bottom: 1px solid rgba(255,255,255,0.05);
          transition: background 0.2s ease;
        }
        .platform-item:last-child { border-bottom: none; }
        .platform-item:hover { background: rgba(255,255,255,0.03); }
        .platform-icon { font-size: 1.5rem; flex-shrink: 0; }
        .platform-info {
          display: flex;
          flex-direction: column;
          gap: 3px;
        }
        .platform-name {
          font-size: 0.9rem;
          font-weight: 700;
          color: var(--text-primary);
        }
        .platform-status {
          font-size: 0.75rem;
          font-weight: 500;
        }
        .status-active { color: var(--success); }
        .status-pending { color: var(--text-muted); }

        /* Privacy Card */
        .privacy-card {
          background: rgba(16,185,129,0.06);
          border: 1px solid rgba(16,185,129,0.2);
          border-radius: var(--radius-lg);
          padding: 20px;
          display: flex;
          gap: 14px;
          align-items: flex-start;
        }
        .privacy-icon { font-size: 1.8rem; flex-shrink: 0; }
        .privacy-title {
          font-size: 0.92rem;
          font-weight: 700;
          color: var(--success);
          margin-bottom: 8px;
        }
        .privacy-body {
          font-size: 0.8rem;
          color: var(--text-secondary);
          line-height: 1.6;
        }

        @media (max-width: 960px) {
          .download-layout {
            grid-template-columns: 1fr;
          }
          .dl-top {
            flex-direction: column;
            align-items: center;
          }
          .guide-steps {
            grid-template-columns: 1fr;
          }
        }
        @media (max-width: 640px) {
          .download-main-card { padding: 24px 18px; }
        }
      `}</style>
    </section>
  );
}

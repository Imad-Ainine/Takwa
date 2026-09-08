'use client';

import React, { useRef } from 'react';
import Image from 'next/image';
import { useTranslations } from 'next-intl';

interface HeroSectionProps {
  apkVersion?: string;
  apkSize?: string;
  apkUrl?: string;
}

export default function HeroSection({
  apkVersion = '1.0.0',
  apkSize = '',
  apkUrl = '#download',
}: HeroSectionProps) {
  const t = useTranslations('HomePage');
  const heroRef = useRef<HTMLDivElement>(null);
  const mockupRef = useRef<HTMLDivElement>(null);
  const contentRef = useRef<HTMLDivElement>(null);

  return (
    <section ref={heroRef} className="hero-section" id="hero">
      {/* Background Ornaments */}
      <div className="hero-glow-bg" aria-hidden="true" />
      <div className="islamic-pattern-bg hero-pattern-overlay" aria-hidden="true" />

      <div className="container hero-grid">
        {/* Left / Text Column */}
        <div ref={contentRef} className="hero-content">
          {/* Trust Badge */}
          <div className="hero-anim-badge">
            <span className="trust-badge">
              <span className="dot" />
              {t('heroBadge')}
            </span>
          </div>

          {/* Heading */}
          <h1 className="hero-title hero-anim-title">
            <span className="gold-text amiri">{t('title')}</span>
          </h1>

          {/* Subtitle */}
          <p className="hero-desc hero-anim-desc">{t('description')}</p>

          {/* Primary & Secondary CTAs */}
          <div className="hero-cta-group hero-anim-cta">
            <a
              href={apkUrl || '#download'}
              className="btn-primary hero-btn-main"
              id="hero-download-cta"
            >
              <svg
                width="20"
                height="20"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2.2"
                strokeLinecap="round"
                strokeLinejoin="round"
                aria-hidden="true"
              >
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                <polyline points="7 10 12 15 17 10" />
                <line x1="12" y1="15" x2="12" y2="3" />
              </svg>
              <span>{t('heroCtaDownload')}</span>
              <span className="cta-sub-badge">v{apkVersion}{apkSize ? ` • ${apkSize}` : ''}</span>
            </a>

            <a href="#features" className="btn-outline">
              <span>{t('heroCtaExplore')}</span>
              <svg
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                aria-hidden="true"
              >
                <line x1="5" y1="12" x2="19" y2="12" />
                <polyline points="12 5 19 12 12 19" />
              </svg>
            </a>
          </div>

          {/* Value Props Pills */}
          <div className="hero-chips-wrap hero-anim-chips">
            <div className="value-chip">
              <span className="chip-icon">🕌</span>
              <span>{t('chipPrayer')}</span>
            </div>
            <div className="value-chip">
              <span className="chip-icon">⚖️</span>
              <span>{t('chipHisab')}</span>
            </div>
            <div className="value-chip">
              <span className="chip-icon">📖</span>
              <span>{t('chipQuran')}</span>
            </div>
            <div className="value-chip">
              <span className="chip-icon">🛡️</span>
              <span>{t('chipPrivacy')}</span>
            </div>
          </div>
        </div>

        {/* Right / 3D Mockup Visual Column */}
        <div ref={mockupRef} className="hero-visual">
          <div className="mockup-stage">
            {/* Ambient Backlight */}
            <div className="mockup-ambient-glow" aria-hidden="true" />

            {/* Secondary Phone (Background Angle) */}
            <div className="mockup-phone mockup-phone-secondary">
              <div className="phone-bezel">
                <div className="phone-speaker" />
                <div className="phone-screen-container">
                  <Image
                    src="/screenshots/2.webp"
                    alt="Takwa Prayer Schedule Screen"
                    width={260}
                    height={550}
                    className="phone-screen-img"
                    sizes="(max-width: 580px) 220px, 260px"
                    priority
                    loading="eager"
                    style={{ width: '100%', height: 'auto', aspectRatio: '580 / 1227', objectFit: 'cover' }}
                  />
                </div>
              </div>
            </div>

            {/* Primary Phone (Foreground Focal) */}
            <div className="mockup-phone mockup-phone-primary">
              <div className="phone-bezel">
                <div className="phone-dynamic-island" />
                <div className="phone-screen-container">
                  <Image
                    src="/screenshots/0.webp"
                    alt="Takwa Main Dashboard Screen"
                    width={290}
                    height={614}
                    className="phone-screen-img"
                    priority
                    loading="eager"
                    sizes="(max-width: 580px) 240px, 290px"
                    style={{ width: '100%', height: 'auto', aspectRatio: '580 / 1227', objectFit: 'cover' }}
                  />
                </div>
              </div>

              {/* Floating Highlight Card 1: Next Prayer */}
              <div className="floating-card-chip card-prayer">
                <div className="floating-icon">🕋</div>
                <div className="floating-text">
                  <span className="floating-title">Fajr • 05:12 AM</span>
                  <span className="floating-desc">Adhan Notification Active</span>
                </div>
              </div>

              {/* Floating Highlight Card 2: Hisab Streak */}
              <div className="floating-card-chip card-streak">
                <div className="floating-icon">✨</div>
                <div className="floating-text">
                  <span className="floating-title">14-Day Streak</span>
                  <span className="floating-desc">Hisab Checklist Complete</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <style jsx>{`
        .hero-section {
          position: relative;
          min-height: 90vh;
          display: flex;
          align-items: center;
          padding: 80px 0 100px;
          overflow: hidden;
          background: linear-gradient(180deg, #04011e 0%, #0a0538 50%, #04011e 100%);
        }
        .hero-glow-bg {
          position: absolute;
          inset: 0;
          background: radial-gradient(
              ellipse at 25% 30%,
              rgba(229, 185, 88, 0.16) 0%,
              transparent 55%
            ),
            radial-gradient(
              ellipse at 75% 60%,
              rgba(58, 175, 169, 0.12) 0%,
              transparent 50%
            );
          pointer-events: none;
        }
        .hero-pattern-overlay {
          position: absolute;
          inset: 0;
          opacity: 0.45;
          pointer-events: none;
        }
        .hero-grid {
          position: relative;
          z-index: 10;
          display: grid;
          grid-template-columns: 1.15fr 0.95fr;
          gap: 60px;
          align-items: center;
        }
        .hero-content {
          max-width: 640px;
        }
        .hero-title {
          font-size: clamp(2.6rem, 5vw, 4.4rem);
          line-height: 1.12;
          margin: 20px 0 22px;
          letter-spacing: -0.01em;
        }
        .hero-desc {
          font-size: 1.18rem;
          line-height: 1.7;
          color: var(--text-secondary);
          margin-bottom: 36px;
        }
        .hero-cta-group {
          display: flex;
          align-items: center;
          gap: 16px;
          flex-wrap: wrap;
          margin-bottom: 38px;
        }
        .cta-sub-badge {
          font-size: 0.75rem;
          background: rgba(0, 0, 0, 0.25);
          color: #000;
          padding: 2px 8px;
          border-radius: var(--radius-pill);
          font-weight: 800;
        }
        .hero-chips-wrap {
          display: flex;
          flex-wrap: wrap;
          gap: 10px;
        }
        .value-chip {
          display: inline-flex;
          align-items: center;
          gap: 8px;
          background: rgba(255, 255, 255, 0.04);
          border: 1px solid rgba(200, 169, 110, 0.16);
          padding: 8px 14px;
          border-radius: var(--radius-pill);
          font-size: 0.85rem;
          color: var(--text-primary);
          backdrop-filter: blur(8px);
        }
        .chip-icon {
          font-size: 1rem;
        }

        /* 3D Mockup Stage */
        .hero-visual {
          position: relative;
          display: flex;
          justify-content: center;
          align-items: center;
        }
        .mockup-stage {
          position: relative;
          width: 440px;
          height: 640px;
          display: flex;
          justify-content: center;
          align-items: center;
        }
        .mockup-ambient-glow {
          position: absolute;
          width: 360px;
          height: 360px;
          border-radius: 50%;
          background: radial-gradient(
            circle,
            rgba(229, 185, 88, 0.35) 0%,
            transparent 70%
          );
          filter: blur(50px);
          z-index: 1;
        }

        /* Mockup Phones */
        .mockup-phone {
          position: absolute;
          border-radius: 46px;
          padding: 10px;
          background: linear-gradient(135deg, #2b254a 0%, #0d0928 100%);
          box-shadow: 0 35px 70px rgba(0, 0, 0, 0.7),
            0 0 0 1px rgba(200, 169, 110, 0.3),
            inset 0 0 0 2px rgba(255, 255, 255, 0.1);
          z-index: 5;
        }
        .phone-bezel {
          position: relative;
          border-radius: 38px;
          overflow: hidden;
          background: #000;
          box-shadow: inset 0 0 12px rgba(0, 0, 0, 0.9);
        }
        .phone-dynamic-island {
          position: absolute;
          top: 12px;
          left: 50%;
          transform: translateX(-50%);
          width: 86px;
          height: 22px;
          background: #000;
          border-radius: 20px;
          z-index: 20;
          box-shadow: 0 0 2px rgba(255, 255, 255, 0.2);
        }
        .phone-speaker {
          position: absolute;
          top: 10px;
          left: 50%;
          transform: translateX(-50%);
          width: 50px;
          height: 5px;
          background: #1a1a1a;
          border-radius: 10px;
          z-index: 20;
        }
        .phone-screen-container {
          position: relative;
          overflow: hidden;
          border-radius: 36px;
          aspect-ratio: 580 / 1227;
        }
        .phone-screen-img {
          display: block;
          width: 100%;
          height: auto;
          aspect-ratio: 580 / 1227;
          object-fit: cover;
          border-radius: 36px;
        }

        @keyframes floatPrimary {
          0%, 100% {
            transform: rotate(-3deg) translate3d(0, 10px, 0);
          }
          50% {
            transform: rotate(-3deg) translate3d(0, 0px, 0);
          }
        }
        @keyframes floatSecondary {
          0%, 100% {
            transform: rotate(10deg) translate3d(90px, -25px, 0);
          }
          50% {
            transform: rotate(10deg) translate3d(90px, -15px, 0);
          }
        }
        @keyframes floatChipTop {
          0%, 100% {
            transform: translate3d(0, 0, 0);
          }
          50% {
            transform: translate3d(0, -8px, 0);
          }
        }
        @keyframes floatChipBottom {
          0%, 100% {
            transform: translate3d(0, 0, 0);
          }
          50% {
            transform: translate3d(0, 8px, 0);
          }
        }

        /* Primary Foreground Phone */
        .mockup-phone-primary {
          width: 290px;
          z-index: 10;
          will-change: transform;
          animation: floatPrimary 4.5s ease-in-out infinite;
        }

        /* Secondary Background Phone */
        .mockup-phone-secondary {
          width: 260px;
          z-index: 4;
          opacity: 0.75;
          filter: brightness(0.85);
          will-change: transform;
          animation: floatSecondary 5.5s ease-in-out infinite 0.5s;
        }

        /* Floating Cards */
        .floating-card-chip {
          position: absolute;
          background: rgba(14, 8, 48, 0.88);
          backdrop-filter: blur(14px);
          border: 1px solid rgba(229, 185, 88, 0.35);
          border-radius: 16px;
          padding: 12px 18px;
          display: flex;
          align-items: center;
          gap: 12px;
          box-shadow: 0 16px 36px rgba(0, 0, 0, 0.5),
            0 0 15px rgba(229, 185, 88, 0.2);
          z-index: 25;
          will-change: transform;
        }
        .card-prayer {
          top: 18%;
          left: -48px;
          animation: floatChipTop 3.8s ease-in-out infinite;
        }
        .card-streak {
          bottom: 15%;
          right: -36px;
          animation: floatChipBottom 4.2s ease-in-out infinite 0.6s;
        }

        @media (prefers-reduced-motion: reduce) {
          .mockup-phone-primary,
          .mockup-phone-secondary,
          .card-prayer,
          .card-streak {
            animation: none !important;
          }
        }
        .floating-icon {
          font-size: 1.5rem;
          background: rgba(229, 185, 88, 0.12);
          width: 42px;
          height: 42px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .floating-text {
          display: flex;
          flex-direction: column;
        }
        .floating-title {
          font-size: 0.9rem;
          font-weight: 700;
          color: var(--gold-light);
        }
        .floating-desc {
          font-size: 0.75rem;
          color: var(--text-secondary);
        }

        @media (max-width: 980px) {
          .hero-grid {
            grid-template-columns: 1fr;
            text-align: center;
            gap: 50px;
          }
          .hero-content {
            margin: 0 auto;
          }
          .hero-cta-group {
            justify-content: center;
          }
          .hero-chips-wrap {
            justify-content: center;
          }
          .mockup-stage {
            transform: scale(0.9);
          }
        }

        @media (max-width: 580px) {
          .hero-section {
            padding: 50px 0 70px;
          }
          .hero-title {
            font-size: 2.2rem;
          }
          .mockup-stage {
            width: 320px;
            height: 520px;
            transform: scale(0.8);
          }
          .mockup-phone-secondary {
            display: none;
          }
          .card-prayer {
            left: -10px;
          }
          .card-streak {
            right: -10px;
          }
        }
      `}</style>
    </section>
  );
}

'use client';

import React, { useEffect, useRef } from 'react';
import { useTranslations } from 'next-intl';

const FEATURE_ICONS = [
  {
    key: 'prayerTimes',
    icon: '🕌',
    color: 'rgba(229, 185, 88, 0.15)',
    border: 'rgba(229, 185, 88, 0.3)',
  },
  {
    key: 'quran',
    icon: '📖',
    color: 'rgba(16, 185, 129, 0.15)',
    border: 'rgba(16, 185, 129, 0.3)',
  },
  {
    key: 'qibla',
    icon: '🧭',
    color: 'rgba(58, 175, 169, 0.15)',
    border: 'rgba(58, 175, 169, 0.3)',
  },
  {
    key: 'checklist',
    icon: '⚖️',
    color: 'rgba(229, 185, 88, 0.12)',
    border: 'rgba(229, 185, 88, 0.25)',
  },
  {
    key: 'azkar',
    icon: '📿',
    color: 'rgba(16, 185, 129, 0.12)',
    border: 'rgba(16, 185, 129, 0.25)',
  },
  {
    key: 'asma',
    icon: '✨',
    color: 'rgba(245, 223, 168, 0.12)',
    border: 'rgba(245, 223, 168, 0.3)',
  },
  {
    key: 'ramadan',
    icon: '🌙',
    color: 'rgba(58, 175, 169, 0.12)',
    border: 'rgba(58, 175, 169, 0.28)',
  },
  {
    key: 'notifications',
    icon: '🛡️',
    color: 'rgba(16, 185, 129, 0.1)',
    border: 'rgba(16, 185, 129, 0.22)',
  },
] as const;

export default function FeaturesSection() {
  const t = useTranslations('HomePage');
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const el = sectionRef.current;
    if (!el) return;
    const pref = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (pref) {
      el.classList.add('features-visible');
      return;
    }
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          el.classList.add('features-visible');
          observer.disconnect();
        }
      },
      { threshold: 0.08, rootMargin: '0px 0px -50px 0px' }
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  return (
    <section ref={sectionRef} className="section features-section" id="features">
      <div className="container">
        {/* Section Header */}
        <div className="features-header">
          <div className="trust-badge" style={{ marginBottom: '20px' }}>
            <span className="dot" />
            {t('featuresTag')}
          </div>
          <h2 className="gold-text features-title">{t('featuresTitle')}</h2>
          <p className="features-subtitle">{t('featuresSubtitle')}</p>
        </div>

        {/* Features Grid */}
        <div className="features-grid">
          {FEATURE_ICONS.map(({ key, icon, color, border }, i) => (
            <div
              key={key}
              className="mihrab-card feature-card"
              style={
                {
                  '--feature-color': color,
                  '--feature-border': border,
                  '--card-delay': `${i * 0.06}s`,
                } as React.CSSProperties
              }
            >
              <div className="feature-icon-wrap">
                <div className="feature-icon-bg" style={{ background: color, borderColor: border }} />
                <span className="feature-icon" aria-hidden="true">{icon}</span>
              </div>
              <h3 className="feature-title">{t(`features.${key}.title`)}</h3>
              <p className="feature-desc">{t(`features.${key}.description`)}</p>
            </div>
          ))}
        </div>
      </div>

      <style jsx>{`
        .features-section {
          background: linear-gradient(180deg, #04011e 0%, #070340 50%, #04011e 100%);
        }

        /* Entrance state — hidden until IntersectionObserver fires */
        .features-header {
          text-align: center;
          max-width: 680px;
          margin: 0 auto 64px;
          opacity: 0;
          transform: translateY(28px);
          transition: opacity 0.75s ease, transform 0.75s ease;
        }
        .feature-card {
          padding: 30px 26px;
          cursor: default;
          opacity: 0;
          transform: translateY(30px);
          transition: border-color 0.3s ease, box-shadow 0.3s ease, opacity 0.55s ease, transform 0.55s ease !important;
          transition-delay: var(--card-delay, 0s), var(--card-delay, 0s), var(--card-delay, 0s), var(--card-delay, 0s);
        }

        /* Visible state — added when section enters viewport */
        .features-visible .features-header {
          opacity: 1;
          transform: translateY(0);
        }
        .features-visible .feature-card {
          opacity: 1;
          transform: translateY(0);
        }

        .features-title {
          font-size: clamp(1.9rem, 3.5vw, 2.9rem);
          line-height: 1.2;
          margin-bottom: 16px;
        }
        .features-subtitle {
          font-size: 1.08rem;
          color: var(--text-secondary);
          line-height: 1.65;
        }
        .features-grid {
          display: grid;
          grid-template-columns: repeat(4, 1fr);
          gap: 20px;
        }
        .feature-card:hover {
          border-color: var(--feature-border, rgba(200, 169, 110, 0.45));
          box-shadow: 0 12px 30px -10px var(--feature-color, rgba(0, 0, 0, 0.5));
        }
        .feature-icon-wrap {
          position: relative;
          width: 58px;
          height: 58px;
          margin-bottom: 22px;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .feature-icon-bg {
          position: absolute;
          inset: 0;
          border-radius: 14px;
          border: 1px solid transparent;
        }
        .feature-icon {
          font-size: 1.75rem;
          position: relative;
          z-index: 1;
        }
        .feature-title {
          font-size: 1.03rem;
          font-weight: 700;
          color: var(--text-primary);
          margin-bottom: 12px;
          line-height: 1.4;
        }
        .feature-desc {
          font-size: 0.875rem;
          color: var(--text-secondary);
          line-height: 1.65;
        }

        @media (max-width: 1100px) {
          .features-grid { grid-template-columns: repeat(3, 1fr); }
        }
        @media (max-width: 768px) {
          .features-grid { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 480px) {
          .features-grid { grid-template-columns: 1fr; }
        }
      `}</style>
    </section>
  );
}

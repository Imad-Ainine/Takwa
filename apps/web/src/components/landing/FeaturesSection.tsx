'use client';

import React, { useEffect, useRef } from 'react';
import { useTranslations } from 'next-intl';
import gsap from 'gsap';
import ScrollTrigger from 'gsap/ScrollTrigger';

if (typeof window !== 'undefined') {
  gsap.registerPlugin(ScrollTrigger);
}

const FEATURE_ICONS = [
  {
    key: 'prayerTimes',
    icon: '🕌',
    gradient: 'from-gold',
    color: 'rgba(229, 185, 88, 0.15)',
    border: 'rgba(229, 185, 88, 0.3)',
  },
  {
    key: 'quran',
    icon: '📖',
    gradient: 'from-emerald',
    color: 'rgba(16, 185, 129, 0.15)',
    border: 'rgba(16, 185, 129, 0.3)',
  },
  {
    key: 'qibla',
    icon: '🧭',
    gradient: 'from-teal',
    color: 'rgba(58, 175, 169, 0.15)',
    border: 'rgba(58, 175, 169, 0.3)',
  },
  {
    key: 'checklist',
    icon: '⚖️',
    gradient: 'from-gold',
    color: 'rgba(229, 185, 88, 0.12)',
    border: 'rgba(229, 185, 88, 0.25)',
  },
  {
    key: 'azkar',
    icon: '📿',
    gradient: 'from-emerald',
    color: 'rgba(16, 185, 129, 0.12)',
    border: 'rgba(16, 185, 129, 0.25)',
  },
  {
    key: 'asma',
    icon: '✨',
    gradient: 'from-gold',
    color: 'rgba(245, 223, 168, 0.12)',
    border: 'rgba(245, 223, 168, 0.3)',
  },
  {
    key: 'ramadan',
    icon: '🌙',
    gradient: 'from-teal',
    color: 'rgba(58, 175, 169, 0.12)',
    border: 'rgba(58, 175, 169, 0.28)',
  },
  {
    key: 'notifications',
    icon: '🛡️',
    gradient: 'from-emerald',
    color: 'rgba(16, 185, 129, 0.1)',
    border: 'rgba(16, 185, 129, 0.22)',
  },
] as const;

export default function FeaturesSection() {
  const t = useTranslations('HomePage');
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (prefersReducedMotion || !sectionRef.current) return;

    gsap.registerPlugin(ScrollTrigger);

    const ctx = gsap.context(() => {
      gsap.from('.features-header', {
        opacity: 0,
        y: 30,
        duration: 0.9,
        ease: 'power3.out',
        scrollTrigger: {
          trigger: '.features-header',
          start: 'top 82%',
        },
      });

      gsap.from('.feature-card', {
        opacity: 0,
        y: 40,
        duration: 0.7,
        ease: 'power3.out',
        stagger: 0.08,
        scrollTrigger: {
          trigger: '.features-grid',
          start: 'top 78%',
        },
      });
    }, sectionRef);

    return () => ctx.revert();
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
          {FEATURE_ICONS.map(({ key, icon, color, border }) => (
            <div
              key={key}
              className="mihrab-card feature-card"
              style={
                {
                  '--feature-color': color,
                  '--feature-border': border,
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
        .features-header {
          text-align: center;
          max-width: 680px;
          margin: 0 auto 64px;
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
        .feature-card {
          padding: 30px 26px;
          cursor: default;
        }
        .feature-card:hover {
          border-color: var(--feature-border, rgba(200, 169, 110, 0.45));
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
          .features-grid {
            grid-template-columns: repeat(3, 1fr);
          }
        }
        @media (max-width: 768px) {
          .features-grid {
            grid-template-columns: repeat(2, 1fr);
          }
        }
        @media (max-width: 480px) {
          .features-grid {
            grid-template-columns: 1fr;
          }
        }
      `}</style>
    </section>
  );
}

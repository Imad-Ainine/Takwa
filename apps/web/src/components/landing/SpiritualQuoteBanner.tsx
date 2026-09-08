'use client';

import React, { useEffect, useRef } from 'react';
import { useTranslations } from 'next-intl';

export default function SpiritualQuoteBanner() {
  const t = useTranslations('HomePage.quote');
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const el = sectionRef.current;
    if (!el) return;
    const pref = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (pref) {
      el.classList.add('quote-visible');
      return;
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          el.classList.add('quote-visible');
          observer.disconnect();
        }
      },
      { threshold: 0.1, rootMargin: '0px 0px -40px 0px' }
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  return (
    <section ref={sectionRef} className="quote-banner-section" aria-label="Quranic Verse">
      <div className="container quote-banner-inner">
        <div className="arch-left" aria-hidden="true" />
        <div className="arch-right" aria-hidden="true" />

        <div className="quote-content">
          <div className="crescent-ornament" aria-hidden="true">
            <span>☽</span>
          </div>
          <p className="arabic-verse amiri">{t('arabic')}</p>
          <p className="translation-text">{t('translation')}</p>
          <p className="surah-ref">{t('surah')}</p>
        </div>
      </div>

      <style jsx>{`
        .quote-banner-section {
          position: relative;
          overflow: hidden;
          padding: 64px 0;
          background: linear-gradient(
            135deg,
            rgba(10, 5, 56, 0.95) 0%,
            rgba(18, 11, 75, 0.98) 50%,
            rgba(10, 5, 56, 0.95) 100%
          );
          border-top: 1px solid rgba(200, 169, 110, 0.18);
          border-bottom: 1px solid rgba(200, 169, 110, 0.18);
        }
        .quote-banner-inner {
          position: relative;
          text-align: center;
          max-width: 820px;
          opacity: 0;
          transform: translateY(24px);
          transition: opacity 0.8s ease, transform 0.8s ease;
        }
        :global(.quote-visible) .quote-banner-inner {
          opacity: 1;
          transform: translateY(0);
        }
        .arch-left,
        .arch-right {
          position: absolute;
          width: 200px;
          height: 200px;
          border-radius: 50%;
          background: radial-gradient(circle, rgba(229, 185, 88, 0.1) 0%, transparent 70%);
          top: -50px;
          pointer-events: none;
        }
        .arch-left { left: -60px; }
        .arch-right { right: -60px; }

        .crescent-ornament {
          font-size: 2.4rem;
          color: var(--gold-vibrant);
          margin-bottom: 20px;
          display: block;
          opacity: 0.75;
          text-shadow: 0 0 20px rgba(229, 185, 88, 0.5);
        }
        .arabic-verse {
          font-size: clamp(1.8rem, 4vw, 3.2rem);
          color: var(--gold-light);
          line-height: 1.7;
          margin-bottom: 24px;
          letter-spacing: 0.03em;
          direction: rtl;
          text-shadow: 0 0 30px rgba(229, 185, 88, 0.2);
        }
        .translation-text {
          font-size: 1.1rem;
          color: var(--text-secondary);
          font-style: italic;
          line-height: 1.7;
          max-width: 620px;
          margin: 0 auto 16px;
        }
        .surah-ref {
          font-size: 0.85rem;
          color: var(--text-muted);
          font-weight: 600;
          letter-spacing: 0.05em;
          text-transform: uppercase;
        }
      `}</style>
    </section>
  );
}

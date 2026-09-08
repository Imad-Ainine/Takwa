'use client';

import React, { useEffect, useRef } from 'react';
import { useTranslations } from 'next-intl';
import gsap from 'gsap';
import ScrollTrigger from 'gsap/ScrollTrigger';

if (typeof window !== 'undefined') {
  gsap.registerPlugin(ScrollTrigger);
}

export default function SpiritualQuoteBanner() {
  const t = useTranslations('HomePage.quote');
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    const pref = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (pref || !sectionRef.current) return;

    gsap.registerPlugin(ScrollTrigger);
    const ctx = gsap.context(() => {
      gsap.from('.quote-banner-inner', {
        opacity: 0, y: 30, duration: 1, ease: 'power3.out',
        scrollTrigger: { trigger: '.quote-banner-inner', start: 'top 85%' },
      });
    }, sectionRef);
    return () => ctx.revert();
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

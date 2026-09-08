'use client';

import React, { useEffect, useRef, useState } from 'react';
import { useTranslations } from 'next-intl';
import gsap from 'gsap';
import ScrollTrigger from 'gsap/ScrollTrigger';



type TabKey = 'all' | 'worship' | 'quran' | 'habits' | 'adhkar';

const SCREENSHOTS = [
  { index: 0, tab: 'worship' as TabKey },  // Home – prayer times & countdown
  { index: 1, tab: 'habits' as TabKey },   // Statistics – weekly performance
  { index: 2, tab: 'quran' as TabKey },    // Quran reader – Surah Al-Fatiha
  { index: 3, tab: 'quran' as TabKey },    // Khatma screen – start a new reading
  { index: 4, tab: 'quran' as TabKey },    // Quran surah list (free reading)
  { index: 5, tab: 'adhkar' as TabKey },   // App drawer / navigation hub
  { index: 6, tab: 'worship' as TabKey },  // Qiyam night prayer screen
  { index: 7, tab: 'worship' as TabKey },  // Home (alternate light mode)
  { index: 8, tab: 'habits' as TabKey },   // Statistics – worship completion
  { index: 9, tab: 'worship' as TabKey },  // Settings – adhan & notification
];

const TABS: TabKey[] = ['all', 'worship', 'quran', 'habits', 'adhkar'];

export default function ScreenshotsShowcase() {
  const t = useTranslations('HomePage.showcase');
  const sectionRef = useRef<HTMLElement>(null);
  const [activeTab, setActiveTab] = useState<TabKey>('all');
  const [selectedIdx, setSelectedIdx] = useState(0);
  const lightboxRef = useRef<HTMLDivElement>(null);

  const filteredShots = SCREENSHOTS.filter(
    (s) => activeTab === 'all' || s.tab === activeTab
  );

  const selectedShot = filteredShots[selectedIdx] ?? filteredShots[0];

  useEffect(() => {
    setSelectedIdx(0);
  }, [activeTab]);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    const pref = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (pref || !sectionRef.current) return;

    gsap.registerPlugin(ScrollTrigger);
    const ctx = gsap.context(() => {
      gsap.from('.screenshots-header', {
        opacity: 0, y: 30, duration: 0.8, ease: 'power3.out',
        scrollTrigger: { trigger: '.screenshots-header', start: 'top 82%' },
      });
      gsap.from('.tab-nav-item', {
        opacity: 0, y: 15, duration: 0.5, stagger: 0.07, ease: 'power2.out',
        scrollTrigger: { trigger: '.tabs-nav', start: 'top 85%' },
      });
      gsap.from('.screenshots-stage', {
        opacity: 0, scale: 0.96, duration: 0.9, ease: 'power3.out',
        scrollTrigger: { trigger: '.screenshots-stage', start: 'top 80%' },
      });
      gsap.from('.thumb-grid-item', {
        opacity: 0, y: 20, duration: 0.5, stagger: 0.06, ease: 'power2.out',
        scrollTrigger: { trigger: '.thumbs-grid', start: 'top 82%' },
      });
    }, sectionRef);
    return () => ctx.revert();
  }, []);

  // Animate lightbox image change
  useEffect(() => {
    if (!lightboxRef.current) return;
    const pref = typeof window !== 'undefined' &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (pref) return;
    gsap.fromTo(lightboxRef.current, { opacity: 0, scale: 0.97 }, { opacity: 1, scale: 1, duration: 0.4, ease: 'power2.out' });
  }, [selectedIdx, activeTab]);

  return (
    <section ref={sectionRef} className="section screenshots-section" id="screenshots">
      <div className="container">
        {/* Header */}
        <div className="screenshots-header">
          <div className="trust-badge" style={{ marginBottom: '20px' }}>
            <span className="dot" />
            {t('tag')}
          </div>
          <h2 className="gold-text screenshots-title">{t('title')}</h2>
          <p className="screenshots-subtitle">{t('subtitle')}</p>
        </div>

        {/* Tabs Navigation */}
        <div className="tabs-nav" role="tablist" aria-label="Screenshot categories">
          {TABS.map((tab) => (
            <button
              key={tab}
              role="tab"
              aria-selected={activeTab === tab}
              className={`tab-nav-item ${activeTab === tab ? 'active' : ''}`}
              onClick={() => setActiveTab(tab)}
            >
              {t(`tabs.${tab}`)}
            </button>
          ))}
        </div>

        {/* Main Showcase Stage */}
        <div className="screenshots-stage">
          {/* Featured Large Preview */}
          <div className="featured-preview">
            <div className="featured-phone-frame" ref={lightboxRef}>
              <div className="featured-dynamic-island" />
              {selectedShot && (
                <img
                  src={`/screenshots/${selectedShot.index}.jpg`}
                  alt={t(`items.${selectedShot.index}.title` as any)}
                  width={500}
                  height={667}
                  className="featured-screen-img w-full"
                  loading="lazy"
                />
              )}
            </div>
            {selectedShot && (
              <div className="featured-caption">
                <h4 className="caption-title">{t(`items.${selectedShot.index}.title` as any)}</h4>
                <p className="caption-desc">{t(`items.${selectedShot.index}.desc` as any)}</p>
              </div>
            )}
          </div>

          {/* Thumbnails Grid */}
          <div className="thumbs-grid">
            {filteredShots.map((shot, i) => (
              <button
                key={shot.index}
                className={`thumb-grid-item ${selectedIdx === i ? 'active' : ''}`}
                onClick={() => setSelectedIdx(i)}
                aria-label={t(`items.${shot.index}.title` as any)}
                aria-pressed={selectedIdx === i}
              >
                <div className="thumb-phone-frame">
                  <img
                    src={`/screenshots/${shot.index}.jpg`}
                    alt={t(`items.${shot.index}.title` as any)}
                    width={110}
                    height={236}
                    className="thumb-screen-img"
                    loading="lazy"
                  />
                  {selectedIdx === i && <div className="thumb-active-overlay" aria-hidden="true" />}
                </div>
              </button>
            ))}
          </div>
        </div>
      </div>

      <style jsx>{`
        .screenshots-section {
          background: linear-gradient(180deg, #04011e 0%, #0a0538 60%, #04011e 100%);
          overflow: hidden;
        }
        .screenshots-header {
          text-align: center;
          max-width: 680px;
          margin: 0 auto 48px;
        }
        .screenshots-title {
          font-size: clamp(1.9rem, 3.5vw, 2.9rem);
          line-height: 1.2;
          margin-bottom: 16px;
        }
        .screenshots-subtitle {
          font-size: 1.08rem;
          color: var(--text-secondary);
          line-height: 1.65;
        }

        /* Tabs */
        .tabs-nav {
          display: flex;
          justify-content: center;
          gap: 10px;
          flex-wrap: wrap;
          margin-bottom: 48px;
        }
        .tab-nav-item {
          padding: 8px 20px;
          border-radius: var(--radius-pill);
          border: 1px solid rgba(200, 169, 110, 0.2);
          background: rgba(255,255,255,0.03);
          color: var(--text-secondary);
          font-size: 0.88rem;
          font-weight: 600;
          cursor: pointer;
          transition: all 0.2s ease;
        }
        .tab-nav-item:hover {
          border-color: rgba(200, 169, 110, 0.4);
          color: var(--text-primary);
          background: rgba(200, 169, 110, 0.08);
        }
        .tab-nav-item.active {
          background: linear-gradient(135deg, rgba(229, 185, 88, 0.18) 0%, rgba(200, 169, 110, 0.1) 100%);
          border-color: var(--gold-vibrant);
          color: var(--gold-light);
        }

        /* Stage */
        .screenshots-stage {
          display: flex;
          gap: 48px;
          align-items: flex-start;
        }

        /* Featured Preview */
        .featured-preview {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 24px;
          flex-shrink: 0;
        }
        .featured-phone-frame {
          position: relative;
          width: 286px;
          background: linear-gradient(135deg, #2b254a 0%, #0d0928 100%);
          border-radius: 44px;
          padding: 10px;
          box-shadow:
            0 40px 80px rgba(0,0,0,0.7),
            0 0 0 1px rgba(200,169,110,0.3),
            inset 0 0 0 2px rgba(255,255,255,0.08),
            0 0 60px rgba(229, 185, 88, 0.12);
          overflow: hidden;
        }
        .featured-dynamic-island {
          position: absolute;
          top: 18px;
          left: 50%;
          transform: translateX(-50%);
          width: 90px;
          height: 24px;
          background: #000;
          border-radius: 20px;
          z-index: 10;
        }
        .featured-screen-img {
          border-radius: 34px;
          display: block;
          width: 100%;
          height: auto;
          object-fit: contain;
        }
        .featured-caption {
          text-align: center;
          max-width: 280px;
        }
        .caption-title {
          font-size: 1rem;
          font-weight: 700;
          color: var(--gold-light);
          margin-bottom: 6px;
        }
        .caption-desc {
          font-size: 0.85rem;
          color: var(--text-secondary);
          line-height: 1.55;
        }

        /* Thumbnail Grid */
        .thumbs-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
          gap: 12px;
          flex: 1;
          align-content: start;
        }
        .thumb-grid-item {
          background: none;
          border: none;
          cursor: pointer;
          padding: 0;
          transition: transform 0.2s ease;
        }
        .thumb-grid-item:hover {
          transform: scale(1.04);
        }
        .thumb-phone-frame {
          position: relative;
          background: linear-gradient(135deg, #241f45 0%, #0e0927 100%);
          border-radius: 18px;
          padding: 4px;
          border: 2px solid transparent;
          transition: all 0.2s ease;
          overflow: hidden;
        }
        .thumb-grid-item.active .thumb-phone-frame {
          border-color: var(--gold-vibrant);
          box-shadow: 0 0 18px rgba(229, 185, 88, 0.35);
        }
        .thumb-screen-img {
          border-radius: 13px;
          display: block;
          width: 100%;
          height: auto;
          object-fit: contain;
        }
        .thumb-active-overlay {
          position: absolute;
          inset: 0;
          background: rgba(229, 185, 88, 0.15);
          border-radius: 13px;
          pointer-events: none;
        }

        @media (max-width: 900px) {
          .screenshots-stage {
            flex-direction: column;
            align-items: center;
          }
          .thumbs-grid {
            grid-template-columns: repeat(5, 90px);
            gap: 10px;
          }
        }

        @media (max-width: 600px) {
          .featured-phone-frame {
            width: 240px;
          }
          .thumbs-grid {
            grid-template-columns: repeat(4, 78px);
          }
        }
      `}</style>
    </section>
  );
}

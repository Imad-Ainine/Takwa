"use client";

import React from 'react';
import { useTranslations } from 'next-intl';

export default function Home() {
  const t = useTranslations('HomePage');

  return (
    <div className="home-container">
      {/* Hero Section */}
      <section className="hero">
        <div className="container hero-content">
          <h1 className="gold-text">{t('title')}</h1>
          <p className="hero-description">
            {t('description')}
          </p>
          <div className="hero-cta">
            <button className="btn-primary">{t('download')}</button>
            <button className="btn-outline">{t('learnMore')}</button>
          </div>
        </div>
        <div className="hero-bg-pattern"></div>
      </section>

      {/* Features Section */}
      <section className="section container">
        <div className="section-header">
          <h2 className="gold-text">{t('featuresTitle')}</h2>
          <p>{t('featuresSubtitle')}</p>
        </div>

        <div className="features-grid">
          <div className="premium-card feature-item">
            <div className="feature-icon">🕋</div>
            <h3>{t('features.prayerTimes.title')}</h3>
            <p>{t('features.prayerTimes.description')}</p>
          </div>
          <div className="premium-card feature-item">
            <div className="feature-icon">📖</div>
            <h3>{t('features.quran.title')}</h3>
            <p>{t('features.quran.description')}</p>
          </div>
          <div className="premium-card feature-item">
            <div className="feature-icon">🧭</div>
            <h3>{t('features.qibla.title')}</h3>
            <p>{t('features.qibla.description')}</p>
          </div>
          <div className="premium-card feature-item">
            <div className="feature-icon">📿</div>
            <h3>{t('features.azkar.title')}</h3>
            <p>{t('features.azkar.description')}</p>
          </div>
          <div className="premium-card feature-item">
            <div className="feature-icon">🌙</div>
            <h3>{t('features.ramadan.title')}</h3>
            <p>{t('features.ramadan.description')}</p>
          </div>
          <div className="premium-card feature-item">
            <div className="feature-icon">🔔</div>
            <h3>{t('features.notifications.title')}</h3>
            <p>{t('features.notifications.description')}</p>
          </div>
        </div>
      </section>

      {/* App Showcase Section */}
      <section className="section showcase">
        <div className="container showcase-content">
          <div className="showcase-text">
            <h2 className="gold-text">{t('showcase.title')}</h2>
            <p>
              {t('showcase.description')}
            </p>
            <ul className="showcase-list">
              {['Premium Dark Mode Default', 'Islamic Geometric Patterns', 'Smooth & Fluid Animations', 'Adaptive Layouts'].map((item, index) => (
                <li key={index}>{t(`showcase.list.${index}`)}</li>
              ))}
            </ul>
          </div>
          <div className="showcase-visual">
            <div className="phone-mockup">
              <div className="phone-screen">
                <div className="screen-header"></div>
                <div className="screen-content">
                  <div className="prayer-chip"></div>
                  <div className="prayer-chip"></div>
                  <div className="prayer-chip"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <style jsx>{`
        .home-container {
          min-height: 100vh;
        }
        .hero {
          position: relative;
          padding: 120px 0;
          text-align: center;
          overflow: hidden;
          background: linear-gradient(180deg, var(--background) 0%, var(--deep) 100%);
        }
        .hero-content {
          position: relative;
          z-index: 2;
        }
        .hero h1 {
          font-size: clamp(2.5rem, 8vw, 4.5rem);
          margin-bottom: 24px;
          line-height: 1.1;
        }
        .hero-description {
          font-size: 1.25rem;
          color: var(--text-secondary);
          max-width: 700px;
          margin: 0 auto 40px;
          line-height: 1.6;
        }
        .hero-cta {
          display: flex;
          gap: 20px;
          justify-content: center;
        }
        .hero-bg-pattern {
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background-image: radial-gradient(var(--gold-dim) 1px, transparent 1px);
          background-size: 40px 40px;
          opacity: 0.3;
          z-index: 1;
        }
        .section-header {
          text-align: center;
          margin-bottom: 60px;
        }
        .section-header h2 {
          font-size: 2.5rem;
          margin-bottom: 15px;
        }
        .section-header p {
          color: var(--text-secondary);
          font-size: 1.1rem;
        }
        .features-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
          gap: 30px;
        }
        .feature-item {
          text-align: center;
        }
        .feature-icon {
          font-size: 3rem;
          margin-bottom: 20px;
        }
        .feature-item h3 {
          margin-bottom: 15px;
          color: var(--gold-light);
        }
        .feature-item p {
          line-height: 1.6;
          color: var(--text-secondary);
        }
        .showcase {
          background: var(--deep);
        }
        .showcase-content {
          display: flex;
          align-items: center;
          gap: 80px;
          flex-wrap: wrap;
        }
        .showcase-text {
          flex: 1;
          min-width: 350px;
        }
        .showcase-text h2 {
          font-size: 2.5rem;
          margin-bottom: 24px;
        }
        .showcase-text p {
          font-size: 1.1rem;
          line-height: 1.7;
          margin-bottom: 30px;
          color: var(--text-secondary);
        }
        .showcase-list {
          list-style: none;
        }
        .showcase-list li {
          margin-bottom: 12px;
          padding-left: 28px;
          position: relative;
          color: var(--text-primary);
        }
        :global([dir="rtl"]) .showcase-list li {
          padding-left: 0;
          padding-right: 28px;
        }
        .showcase-list li::before {
          content: '✓';
          position: absolute;
          left: 0;
          color: var(--gold);
          font-weight: bold;
        }
        :global([dir="rtl"]) .showcase-list li::before {
          left: auto;
          right: 0;
        }
        .showcase-visual {
          flex: 1;
          display: flex;
          justify-content: center;
          min-width: 300px;
        }
        .phone-mockup {
          width: 280px;
          height: 560px;
          background: #000;
          border: 12px solid #1a1a1a;
          border-radius: 40px;
          position: relative;
          box-shadow: 0 30px 60px rgba(0,0,0,0.5), var(--gold-shadow);
        }
        .phone-screen {
          width: 100%;
          height: 100%;
          background: var(--background);
          border-radius: 28px;
          overflow: hidden;
          padding: 20px;
        }
        .screen-header {
          height: 150px;
          background: var(--card-gradient);
          border-radius: 20px;
          margin-bottom: 20px;
          border: 1px solid var(--gold-dim);
        }
        .prayer-chip {
          height: 60px;
          background: var(--card);
          margin-bottom: 15px;
          border-radius: 12px;
          border: 1px solid var(--border);
        }
        @media (max-width: 768px) {
          .showcase-content {
            flex-direction: column;
            text-align: center;
          }
          .showcase-list li {
            padding-left: 0;
            padding-right: 0;
          }
          .showcase-list li::before {
            display: none;
          }
        }
      `}</style>
    </div>
  );
}

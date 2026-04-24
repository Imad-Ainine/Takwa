"use client";

import React from 'react';
import { useTranslations } from 'next-intl';

export default function PrivacyPolicy() {
  const t = useTranslations('Privacy');

  return (
    <div className="policy-page">
      <div className="container">
        <h1 className="gold-text amiri">{t('title')}</h1>
        <p className="last-updated">{t('lastUpdated')}</p>

        <section className="policy-section">
          <h2>{t('sections.intro.title')}</h2>
          <p>{t('sections.intro.content')}</p>
        </section>

        <section className="policy-section">
          <h2>{t('sections.collect.title')}</h2>
          <p>{t('sections.collect.content')}</p>
          <ul>
            {[0, 1, 2].map((i) => (
              <li key={i}>{t(`sections.collect.items.${i}`)}</li>
            ))}
          </ul>
        </section>

        <section className="policy-section">
          <h2>{t('sections.use.title')}</h2>
          <p>{t('sections.use.content')}</p>
          <ul>
            {[0, 1, 2, 3].map((i) => (
              <li key={i}>{t(`sections.use.items.${i}`)}</li>
            ))}
          </ul>
        </section>

        <section className="policy-section">
          <h2>{t('sections.thirdParty.title')}</h2>
          <p>{t('sections.thirdParty.content')}</p>
        </section>

        <section className="policy-section">
          <h2>{t('sections.security.title')}</h2>
          <p>{t('sections.security.content')}</p>
        </section>

        <section className="policy-section">
          <h2>{t('sections.contact.title')}</h2>
          <p>
            {t('sections.contact.content')} 
            <span className="gold-text"> support@takwa-app.com</span>
          </p>
        </section>
      </div>

      <style jsx>{`
        .policy-page {
          padding: 100px 0;
          line-height: 1.8;
          color: var(--text-secondary);
        }
        .policy-page h1 {
          font-size: 3rem;
          margin-bottom: 10px;
        }
        .last-updated {
          margin-bottom: 40px;
          font-style: italic;
        }
        .policy-section {
          margin-bottom: 40px;
          background: var(--card);
          padding: 30px;
          border-radius: var(--radius-card);
          border: 1px solid var(--border);
        }
        .policy-section h2 {
          color: var(--gold-light);
          margin-bottom: 20px;
          font-family: 'Amiri', serif;
        }
        .policy-section p {
          margin-bottom: 15px;
        }
        .policy-section ul {
          padding-left: 20px;
          margin-bottom: 15px;
        }
        :global([dir="rtl"]) .policy-section ul {
          padding-left: 0;
          padding-right: 20px;
        }
        .policy-section ul li {
          margin-bottom: 10px;
        }
        .policy-section strong {
          color: var(--text-primary);
        }
      `}</style>
    </div>
  );
}

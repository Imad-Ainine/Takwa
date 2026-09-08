"use client";

import React from 'react';
import { useTranslations } from 'next-intl';

export default function Support() {
  const t = useTranslations('Support');

  return (
    <div className="support-page">
      <div className="container">
        <div className="support-header">
          <h1 className="gold-text amiri">{t('title')}</h1>
          <p>{t('subtitle')}</p>
        </div>

        <div className="support-grid">
          <div className="premium-card support-card">
            <div className="icon">📧</div>
            <h2>{t('cards.email.title')}</h2>
            <p>{t('cards.email.content')}</p>
            <a href="mailto:support@takwa-app.com" className="support-link gold-text">support@takwa-app.com</a>
          </div>

          <div className="premium-card support-card">
            <div className="icon">💬</div>
            <h2>{t('cards.social.title')}</h2>
            <p>{t('cards.social.content')}</p>
            <div className="social-links">
              <span className="gold-text">Twitter</span>
              <span className="gold-text">Instagram</span>
              <span className="gold-text">Facebook</span>
            </div>
          </div>

          <div className="premium-card support-card">
            <div className="icon">❓</div>
            <h2>{t('cards.faq.title')}</h2>
            <p>{t('cards.faq.content')}</p>
            <button type="button" className="btn-outline" style={{ marginTop: '10px' }}>{t('cards.faq.button')}</button>
          </div>
        </div>

        <div className="contact-form-section">
          <h2 className="amiri gold-text">{t('form.title')}</h2>
          <form className="contact-form">
            <div className="form-group">
              <label>{t('form.name')}</label>
              <input type="text" placeholder={t('form.placeholderName')} />
            </div>
            <div className="form-group">
              <label>{t('form.email')}</label>
              <input type="email" placeholder={t('form.placeholderEmail')} />
            </div>
            <div className="form-group">
              <label>{t('form.message')}</label>
              <textarea placeholder={t('form.placeholderMessage')} rows={5}></textarea>
            </div>
            <button type="submit" className="btn-primary" onClick={(e) => e.preventDefault()}>
              {t('form.submit')}
            </button>
          </form>
        </div>
      </div>

      <style jsx>{`
        .support-page {
          padding: 100px 0;
        }
        .support-header {
          text-align: center;
          margin-bottom: 60px;
        }
        .support-header h1 {
          font-size: 3.5rem;
          margin-bottom: 15px;
        }
        .support-header p {
          font-size: 1.2rem;
          color: var(--text-secondary);
        }
        .support-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
          gap: 30px;
          margin-bottom: 80px;
        }
        .support-card {
          text-align: center;
        }
        .support-card .icon {
          font-size: 2.5rem;
          margin-bottom: 15px;
        }
        .support-card h2 {
          font-size: 1.3rem;
          margin-bottom: 12px;
          color: var(--text-primary);
        }
        .support-card p {
          margin-bottom: 15px;
          color: var(--text-secondary);
          line-height: 1.6;
        }
        .support-link {
          font-weight: 600;
          font-size: 1.1rem;
        }
        .social-links {
          display: flex;
          justify-content: center;
          gap: 15px;
          font-weight: 600;
        }
        .contact-form-section {
          max-width: 600px;
          margin: 0 auto;
          background: var(--card);
          padding: 40px;
          border-radius: var(--radius-card);
          border: 1px solid var(--border);
        }
        .contact-form-section h2 {
          text-align: center;
          font-size: 2.2rem;
          margin-bottom: 30px;
        }
        .contact-form {
          display: flex;
          flex-direction: column;
          gap: 20px;
        }
        .form-group {
          display: flex;
          flex-direction: column;
          gap: 8px;
        }
        .form-group label {
          font-weight: 600;
          color: var(--text-secondary);
          font-size: 0.9rem;
        }
        .form-group input, 
        .form-group textarea {
          padding: 14px;
          background: var(--card-light);
          border: 1px solid var(--border);
          border-radius: var(--radius-input);
          color: var(--text-primary);
          font-family: 'Inter', sans-serif;
        }
        .form-group input:focus, 
        .form-group textarea:focus {
          outline: none;
          border-color: var(--gold);
        }
      `}</style>
    </div>
  );
}

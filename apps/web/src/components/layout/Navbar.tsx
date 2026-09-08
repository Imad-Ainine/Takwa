'use client';

import React, { useState, useEffect } from 'react';
import { Link } from '@/i18n/routing';
import Image from 'next/image';
import { useTranslations } from 'next-intl';
import LanguageSwitcher from '../common/LanguageSwitcher';

export default function Navbar() {
  const t = useTranslations('Navigation');
  const [isScrolled, setIsScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => setIsScrolled(window.scrollY > 20);
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Close mobile menu on resize
  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth > 860) setMobileOpen(false);
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return (
    <>
      <nav className={`navbar ${isScrolled ? 'navbar-scrolled' : ''}`} role="navigation" aria-label="Main Navigation">
        <div className="container nav-content">
          {/* Logo */}
          <Link href="/" className="logo" aria-label="Takwa Home">
            <Image
              src="/logo.png"
              alt="Takwa Logo"
              width={130}
              height={55}
              className="logo-img"
              sizes="130px"
              priority
            />
          </Link>

          {/* Desktop Nav Links */}
          <div className="nav-links">
            <a href="#features" className="nav-link">{t('features')}</a>
            <a href="#screenshots" className="nav-link">{t('screenshots')}</a>
            <Link href="/support" className="nav-link">{t('support')}</Link>
            <Link href="/privacy" className="nav-link">{t('privacy')}</Link>
            <LanguageSwitcher />
            <a
              href="#download"
              className="btn-primary nav-cta"
              id="nav-download-btn"
            >
              {t('download')}
            </a>
          </div>

          {/* Mobile Hamburger */}
          <button
            className={`hamburger ${mobileOpen ? 'hamburger-open' : ''}`}
            onClick={() => setMobileOpen(!mobileOpen)}
            aria-expanded={mobileOpen}
            aria-label="Toggle navigation menu"
          >
            <span className="ham-bar" />
            <span className="ham-bar" />
            <span className="ham-bar" />
          </button>
        </div>

        {/* Mobile Drawer */}
        {mobileOpen && (
          <div className="mobile-drawer" role="dialog" aria-modal="true" aria-label="Mobile Navigation">
            <div className="mobile-nav-links">
              <a href="#features" className="mobile-nav-link" onClick={() => setMobileOpen(false)}>
                {t('features')}
              </a>
              <a href="#screenshots" className="mobile-nav-link" onClick={() => setMobileOpen(false)}>
                {t('screenshots')}
              </a>
              <Link href="/support" className="mobile-nav-link" onClick={() => setMobileOpen(false)}>
                {t('support')}
              </Link>
              <Link href="/privacy" className="mobile-nav-link" onClick={() => setMobileOpen(false)}>
                {t('privacy')}
              </Link>
              <div className="mobile-lang-wrap">
                <LanguageSwitcher />
              </div>
              <a
                href="#download"
                className="btn-primary mobile-cta-btn"
                onClick={() => setMobileOpen(false)}
              >
                {t('download')}
              </a>
            </div>
          </div>
        )}
      </nav>

      <style jsx>{`
        .navbar {
          height: 72px;
          display: flex;
          align-items: center;
          background: rgba(4, 1, 30, 0.7);
          backdrop-filter: blur(16px);
          -webkit-backdrop-filter: blur(16px);
          position: sticky;
          top: 0;
          z-index: 999;
          border-bottom: 1px solid rgba(200, 169, 110, 0.1);
          transition: background 0.3s ease, box-shadow 0.3s ease, border-color 0.3s ease;
        }
        .navbar-scrolled {
          background: rgba(4, 1, 30, 0.95);
          border-bottom-color: rgba(200, 169, 110, 0.22);
          box-shadow: 0 4px 30px rgba(0,0,0,0.4);
        }
        .nav-content {
          display: flex;
          justify-content: space-between;
          align-items: center;
          width: 100%;
        }
        .logo {
          display: flex;
          align-items: center;
        }
        .logo-img {
          object-fit: contain;
          height: 44px;
          width: auto;
        }
        .nav-links {
          display: flex;
          align-items: center;
          gap: 28px;
        }
        .nav-link {
          font-size: 0.9rem;
          font-weight: 500;
          color: var(--text-secondary);
          transition: color 0.2s ease;
        }
        .nav-link:hover {
          color: var(--gold-light);
        }
        .nav-cta {
          font-size: 0.88rem;
          padding: 10px 22px;
        }

        /* Hamburger */
        .hamburger {
          display: none;
          flex-direction: column;
          gap: 5px;
          background: none;
          border: none;
          cursor: pointer;
          padding: 6px;
        }
        .ham-bar {
          width: 22px;
          height: 2px;
          background: var(--text-primary);
          border-radius: 2px;
          transition: all 0.3s ease;
          display: block;
        }
        .hamburger-open .ham-bar:nth-child(1) {
          transform: translateY(7px) rotate(45deg);
        }
        .hamburger-open .ham-bar:nth-child(2) {
          opacity: 0;
        }
        .hamburger-open .ham-bar:nth-child(3) {
          transform: translateY(-7px) rotate(-45deg);
        }

        /* Mobile Drawer */
        .mobile-drawer {
          position: absolute;
          top: 72px;
          left: 0;
          right: 0;
          background: rgba(7, 3, 44, 0.98);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          border-bottom: 1px solid rgba(200, 169, 110, 0.2);
          box-shadow: 0 20px 40px rgba(0,0,0,0.5);
          z-index: 998;
          animation: drawerSlide 0.25s ease-out;
        }
        @keyframes drawerSlide {
          from { opacity: 0; transform: translateY(-10px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .mobile-nav-links {
          display: flex;
          flex-direction: column;
          padding: 20px 24px 28px;
          gap: 4px;
        }
        .mobile-nav-link {
          display: block;
          padding: 14px 16px;
          font-size: 1rem;
          font-weight: 500;
          color: var(--text-secondary);
          border-radius: var(--radius-sm);
          transition: all 0.2s ease;
        }
        .mobile-nav-link:hover {
          color: var(--gold-light);
          background: rgba(200, 169, 110, 0.06);
        }
        .mobile-lang-wrap {
          padding: 10px 16px;
        }
        .mobile-cta-btn {
          margin-top: 10px;
          text-align: center;
          font-size: 1rem;
        }

        @media (max-width: 860px) {
          .nav-links { display: none; }
          .hamburger { display: flex; }
        }
      `}</style>
    </>
  );
}

'use client';

import { useLocale } from 'next-intl';
import { usePathname, useRouter } from '@/i18n/routing';
import { useTransition } from 'react';

export default function LanguageSwitcher() {
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();
  const [isPending, startTransition] = useTransition();

  function onLanguageChange(nextLocale: 'en' | 'ar') {
    startTransition(() => {
      router.replace(pathname, { locale: nextLocale });
    });
  }

  return (
    <div className="lang-switcher">
      <button 
        onClick={() => onLanguageChange('en')}
        className={locale === 'en' ? 'active' : ''}
        disabled={isPending}
      >
        EN
      </button>
      <span className="separator">|</span>
      <button 
        onClick={() => onLanguageChange('ar')}
        className={locale === 'ar' ? 'active' : ''}
        disabled={isPending}
      >
        AR
      </button>

      <style jsx>{`
        .lang-switcher {
          display: flex;
          align-items: center;
          gap: 8px;
          margin: 0 15px;
          font-weight: 600;
          font-size: 0.9rem;
        }
        button {
          background: none;
          border: none;
          color: var(--text-secondary);
          cursor: pointer;
          padding: 4px 8px;
          transition: color 0.2s, background-color 0.2s;
          border-radius: 4px;
        }
        button:hover {
          color: var(--gold);
        }
        button.active {
          color: var(--gold);
          background: rgba(212, 175, 55, 0.1);
        }
        button:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
        .separator {
          color: var(--border);
          font-weight: normal;
        }
      `}</style>
    </div>
  );
}

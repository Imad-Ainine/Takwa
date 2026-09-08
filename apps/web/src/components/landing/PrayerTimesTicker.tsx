'use client';

import React, { useEffect, useState } from 'react';
import { useTranslations, useLocale } from 'next-intl';

interface PrayerSchedule {
  name: string;
  key: 'fajr' | 'dhuhr' | 'asr' | 'maghrib' | 'isha';
  time: string;
  hours: number;
  minutes: number;
}

export default function PrayerTimesTicker() {
  const t = useTranslations('HomePage.ticker');
  const locale = useLocale();

  // Representative standard prayer timetable (dynamically updated relative to user time)
  const [schedule, setSchedule] = useState<PrayerSchedule[]>([
    { name: t('fajr'), key: 'fajr', time: '05:12', hours: 5, minutes: 12 },
    { name: t('dhuhr'), key: 'dhuhr', time: '12:45', hours: 12, minutes: 45 },
    { name: t('asr'), key: 'asr', time: '16:15', hours: 16, minutes: 15 },
    { name: t('maghrib'), key: 'maghrib', time: '18:50', hours: 18, minutes: 50 },
    { name: t('isha'), key: 'isha', time: '20:18', hours: 20, minutes: 18 },
  ]);

  const [nextPrayer, setNextPrayer] = useState<{ name: string; countdown: string }>({
    name: schedule[0].name,
    countdown: '00:00:00',
  });

  useEffect(() => {
    let isMounted = true;

    function updateCountdown() {
      if (!isMounted) return;
      const now = new Date();
      const currentMinutes = now.getHours() * 60 + now.getMinutes();

      let upcoming = schedule.find(
        (p) => p.hours * 60 + p.minutes > currentMinutes
      );

      let targetDate = new Date();
      if (!upcoming) {
        upcoming = schedule[0];
        targetDate.setDate(targetDate.getDate() + 1);
      }

      targetDate.setHours(upcoming.hours, upcoming.minutes, 0, 0);

      const diffMs = Math.max(0, targetDate.getTime() - now.getTime());
      const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
      const diffMins = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
      const diffSecs = Math.floor((diffMs % (1000 * 60)) / 1000);

      const formattedCountdown = `${String(diffHours).padStart(2, '0')}:${String(
        diffMins
      ).padStart(2, '0')}:${String(diffSecs).padStart(2, '0')}`;

      setNextPrayer({
        name: upcoming.name,
        countdown: formattedCountdown,
      });
    }

    updateCountdown();
    const interval = setInterval(updateCountdown, 1000);
    return () => {
      isMounted = false;
      clearInterval(interval);
    };
  }, [schedule]);


  return (
    <div className="prayer-ticker-wrap" aria-label="Daily Prayer Times Bar">
      <div className="container ticker-container">
        {/* Calligraphy Crest */}
        <div className="bismillah-crest">
          <span className="bismillah-arabic amiri">﷽</span>
        </div>

        {/* Next Prayer Live Pill */}
        <div className="next-prayer-pill">
          <span className="live-indicator" aria-hidden="true" />
          <span className="pill-label">{t('nextPrayer')}:</span>
          <span className="pill-name">{nextPrayer.name}</span>
          <span className="pill-countdown">{nextPrayer.countdown}</span>
        </div>

        {/* Schedule Ticker Items */}
        <div className="schedule-items">
          {schedule.map((p) => {
            const isNext = p.name === nextPrayer.name;
            return (
              <div
                key={p.key}
                className={`prayer-time-chip ${isNext ? 'is-next' : ''}`}
              >
                <span className="prayer-label">{t(p.key)}</span>
                <span className="prayer-hour">{p.time}</span>
              </div>
            );
          })}
        </div>
      </div>

      <style jsx>{`
        .prayer-ticker-wrap {
          background: rgba(10, 5, 56, 0.85);
          backdrop-filter: blur(12px);
          -webkit-backdrop-filter: blur(12px);
          border-bottom: 1px solid rgba(200, 169, 110, 0.18);
          font-size: 0.82rem;
          color: var(--text-secondary);
          position: relative;
          z-index: 100;
        }
        .ticker-container {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 8px 24px;
          gap: 16px;
          flex-wrap: wrap;
        }
        .bismillah-crest {
          display: flex;
          align-items: center;
          gap: 8px;
        }
        .bismillah-arabic {
          font-size: 1.35rem;
          color: var(--gold-vibrant);
          letter-spacing: 0.05em;
          line-height: 1;
        }
        .next-prayer-pill {
          display: flex;
          align-items: center;
          gap: 7px;
          background: rgba(229, 185, 88, 0.12);
          border: 1px solid rgba(229, 185, 88, 0.3);
          padding: 4px 14px;
          border-radius: var(--radius-pill);
          font-weight: 600;
          color: var(--gold-light);
        }
        .live-indicator {
          width: 7px;
          height: 7px;
          border-radius: 50%;
          background: var(--emerald);
          box-shadow: 0 0 8px var(--emerald);
          display: inline-block;
          animation: pulseGlow 2s infinite ease-in-out;
        }
        @keyframes pulseGlow {
          0%, 100% { transform: scale(1); opacity: 1; }
          50% { transform: scale(1.3); opacity: 0.7; }
        }
        .pill-label {
          color: var(--text-muted);
          font-weight: 500;
        }
        .pill-name {
          color: #fff;
        }
        .pill-countdown {
          font-family: 'Courier New', monospace;
          font-weight: 700;
          color: var(--gold-vibrant);
          letter-spacing: 0.05em;
        }
        .schedule-items {
          display: flex;
          align-items: center;
          gap: 12px;
        }
        .prayer-time-chip {
          display: flex;
          align-items: center;
          gap: 6px;
          padding: 3px 10px;
          border-radius: 6px;
          background: rgba(255, 255, 255, 0.03);
          border: 1px solid rgba(255, 255, 255, 0.05);
          transition: all 0.2s ease;
        }
        .prayer-time-chip.is-next {
          background: rgba(200, 169, 110, 0.14);
          border-color: rgba(200, 169, 110, 0.4);
          color: var(--gold-light);
        }
        .prayer-label {
          font-weight: 500;
        }
        .prayer-hour {
          font-weight: 700;
          color: var(--text-primary);
        }
        .prayer-time-chip.is-next .prayer-hour {
          color: var(--gold-vibrant);
        }
        @media (max-width: 860px) {
          .schedule-items {
            display: none;
          }
          .ticker-container {
            justify-content: center;
          }
        }
      `}</style>
    </div>
  );
}

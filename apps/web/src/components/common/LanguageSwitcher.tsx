'use client';

import { useLocale } from 'next-intl';
import { usePathname, useRouter } from '@/i18n/routing';
import { useTransition, useState, useRef, useEffect } from 'react';

const LOCALES = [
	{ code: 'ar', label: 'العربية', short: 'عربي', dir: 'rtl' },
	{ code: 'en', label: 'English', short: 'EN', dir: 'ltr' },
	{ code: 'fr', label: 'Français', short: 'FR', dir: 'ltr' },
] as const;

type LocaleCode = (typeof LOCALES)[number]['code'];

export default function LanguageSwitcher() {
	const currentLocale = useLocale() as LocaleCode;
	const router = useRouter();
	const pathname = usePathname();
	const [isPending, startTransition] = useTransition();
	const [isOpen, setIsOpen] = useState(false);
	const dropdownRef = useRef<HTMLDivElement>(null);

	const activeLocaleObj =
		LOCALES.find((l) => l.code === currentLocale) || LOCALES[0];

	function switchLocale(nextLocale: LocaleCode) {
		if (nextLocale === currentLocale) {
			setIsOpen(false);
			return;
		}

		setIsOpen(false);
		startTransition(() => {
			router.replace(pathname, { locale: nextLocale });
		});
	}

	// Close dropdown when clicking outside
	useEffect(() => {
		function handleClickOutside(event: MouseEvent) {
			if (
				dropdownRef.current &&
				!dropdownRef.current.contains(event.target as Node)
			) {
				setIsOpen(false);
			}
		}

		if (isOpen) {
			document.addEventListener('mousedown', handleClickOutside);
		}
		return () => {
			document.removeEventListener('mousedown', handleClickOutside);
		};
	}, [isOpen]);

	return (
		<div className="lang-switcher-wrapper" ref={dropdownRef} dir="ltr">
			{/* Segmented control for larger screens */}
			<div className="segmented-control">
				{LOCALES.map((l) => {
					const isActive = currentLocale === l.code;
					return (
						<button
							key={l.code}
							type="button"
							onClick={() => switchLocale(l.code)}
							className={`segment-btn ${isActive ? 'active' : ''}`}
							disabled={isPending}
							aria-label={`Switch to ${l.label}`}
							aria-pressed={isActive}
						>
							<span className="lang-name">{l.short}</span>
						</button>
					);
				})}
			</div>

			{/* Dropdown toggle for compact spaces / mobile */}
			<div className="dropdown-container">
				<button
					type="button"
					className={`dropdown-trigger ${isOpen ? 'open' : ''}`}
					onClick={() => setIsOpen((prev) => !prev)}
					disabled={isPending}
					aria-expanded={isOpen}
					aria-haspopup="listbox"
					aria-label={`Select language (current: ${activeLocaleObj.label})`}
				>
					<svg
						className="globe-icon"
						viewBox="0 0 24 24"
						fill="none"
						stroke="currentColor"
						strokeWidth="2"
						strokeLinecap="round"
						strokeLinejoin="round"
						aria-hidden="true"
					>
						<circle cx="12" cy="12" r="10" />
						<line x1="2" y1="12" x2="22" y2="12" />
						<path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
					</svg>
					<span className="current-code">{activeLocaleObj.short}</span>
					<svg
						className={`chevron-icon ${isOpen ? 'rotated' : ''}`}
						viewBox="0 0 24 24"
						fill="none"
						stroke="currentColor"
						strokeWidth="2.5"
						strokeLinecap="round"
						strokeLinejoin="round"
						aria-hidden="true"
					>
						<polyline points="6 9 12 15 18 9" />
					</svg>
				</button>

				{isOpen && (
					<ul className="dropdown-menu" role="listbox">
						{LOCALES.map((l) => {
							const isActive = currentLocale === l.code;
							return (
								<li key={l.code} role="option" aria-selected={isActive}>
									<button
										type="button"
										className={`menu-item ${isActive ? 'selected' : ''}`}
										onClick={() => switchLocale(l.code)}
										dir={l.dir}
										aria-label={`Switch language to ${l.label}`}
									>
										<span className="item-label">{l.label}</span>
										<span className="item-badge">{l.code.toUpperCase()}</span>
										{isActive && (
											<svg
												className="check-icon"
												viewBox="0 0 24 24"
												fill="none"
												stroke="currentColor"
												strokeWidth="2.5"
												strokeLinecap="round"
												strokeLinejoin="round"
											>
												<polyline points="20 6 9 17 4 12" />
											</svg>
										)}
									</button>
								</li>
							);
						})}
					</ul>
				)}
			</div>

			<style jsx>{`
				.lang-switcher-wrapper {
					position: relative;
					display: inline-flex;
					align-items: center;
				}

				/* Segmented Control */
				.segmented-control {
					display: flex;
					align-items: center;
					background: rgba(17, 24, 39, 0.8);
					border: 1px solid var(--border);
					border-radius: 9999px;
					padding: 3px;
					gap: 2px;
					backdrop-filter: blur(8px);
					box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
				}

				.segment-btn {
					background: transparent;
					border: none;
					color: var(--text-secondary);
					font-size: 0.82rem;
					font-weight: 600;
					padding: 5px 12px;
					border-radius: 9999px;
					cursor: pointer;
					transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
					display: flex;
					align-items: center;
					justify-content: center;
					white-space: nowrap;
				}

				.segment-btn:hover:not(:disabled) {
					color: var(--text-primary);
					background: rgba(200, 169, 110, 0.1);
				}

				.segment-btn.active {
					background: var(--gold-gradient);
					color: #04011e;
					box-shadow: 0 2px 10px rgba(200, 169, 110, 0.35);
					font-weight: 700;
				}

				.segment-btn:disabled {
					opacity: 0.6;
					cursor: wait;
				}

				/* Dropdown (Responsive) */
				.dropdown-container {
					display: none;
					position: relative;
				}

				.dropdown-trigger {
					display: flex;
					align-items: center;
					gap: 6px;
					background: rgba(17, 24, 39, 0.8);
					border: 1px solid var(--border);
					color: var(--text-primary);
					padding: 6px 12px;
					border-radius: 9999px;
					font-size: 0.85rem;
					font-weight: 600;
					cursor: pointer;
					transition: all 0.2s ease;
				}

				.dropdown-trigger:hover,
				.dropdown-trigger.open {
					border-color: var(--gold);
					background: rgba(26, 35, 50, 0.95);
				}

				.globe-icon {
					width: 16px;
					height: 16px;
					color: var(--gold);
				}

				.chevron-icon {
					width: 14px;
					height: 14px;
					color: var(--text-secondary);
					transition: transform 0.2s ease;
				}

				.chevron-icon.rotated {
					transform: rotate(180deg);
				}

				.dropdown-menu {
					position: absolute;
					top: calc(100% + 8px);
					right: 0;
					min-width: 160px;
					background: var(--card);
					border: 1px solid var(--border);
					border-radius: 12px;
					padding: 6px;
					list-style: none;
					box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4);
					backdrop-filter: blur(12px);
					z-index: 1100;
					display: flex;
					flex-direction: column;
					gap: 2px;
					animation: fadeIn 0.15s ease-out;
				}

				@keyframes fadeIn {
					from {
						opacity: 0;
						transform: translateY(-4px);
					}
					to {
						opacity: 1;
						transform: translateY(0);
					}
				}

				.menu-item {
					width: 100%;
					display: flex;
					align-items: center;
					justify-content: space-between;
					gap: 8px;
					padding: 8px 12px;
					border: none;
					background: transparent;
					color: var(--text-secondary);
					border-radius: 8px;
					font-size: 0.88rem;
					font-weight: 500;
					cursor: pointer;
					transition: all 0.15s ease;
					text-align: inherit;
				}

				.menu-item:hover {
					background: var(--gold-dim);
					color: var(--gold-light);
				}

				.menu-item.selected {
					background: var(--gold-dim);
					color: var(--gold);
					font-weight: 700;
				}

				.item-badge {
					font-size: 0.72rem;
					color: var(--text-dim);
					font-family: monospace;
					background: rgba(255, 255, 255, 0.05);
					padding: 2px 6px;
					border-radius: 4px;
				}

				.check-icon {
					width: 14px;
					height: 14px;
					color: var(--gold);
					margin-left: auto;
				}

				@media (max-width: 900px) {
					.segmented-control {
						display: none;
					}
					.dropdown-container {
						display: block;
					}
				}
			`}</style>
		</div>
	);
}

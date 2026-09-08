'use client';

import Image from 'next/image';
import {Link} from '@/i18n/routing';
import { useTranslations } from 'next-intl';

export default function Footer() {
	const currentYear = new Date().getFullYear();
	const t = useTranslations('Navigation');
	const th = useTranslations('HomePage');

	return (
		<footer className='footer'>
			<div className='container footer-content'>
				<div className='footer-brand'>
					<div className='logo'>
						<Image
							src='/logo.png'
							alt='Takwa Logo'
							width={132}
							height={60}
							className='logo-img'
							style={{ aspectRatio: '1492 / 678', height: 'auto' }}
						/>
					</div>
					<p className='footer-tagline'>
						{th('description')}
					</p>
				</div>

				<div className='footer-grid'>
					<div className='footer-column'>
						<h3>{t('home')}</h3>
						<ul>
							<li>
								<Link href='/'>{t('home')}</Link>
							</li>
							<li>
								<Link href='/support'>{t('support')}</Link>
							</li>
						</ul>
					</div>
					<div className='footer-column'>
						<h3>{t('legal')}</h3>
						<ul>
							<li>
								<Link href='/privacy'>{t('privacy')}</Link>
							</li>
							<li>
								<Link href='/terms'>{t('terms')}</Link>
							</li>
						</ul>
					</div>
				</div>
			</div>

			<div className='footer-bottom'>
				<div className='container'>
					<p>&copy; {currentYear} Takwa App. All rights reserved.</p>
				</div>
			</div>

			<style jsx>{`
				.footer {
					background: var(--deep);
					padding: 60px 0 30px;
					border-top: 1px solid var(--border);
					color: var(--text-secondary);
				}
				.footer-content {
					display: flex;
					justify-content: space-between;
					flex-wrap: wrap;
					gap: 40px;
					margin-bottom: 40px;
				}
				.footer-brand {
					flex: 1;
					min-width: 250px;
				}
				.logo {
					display: flex;
					align-items: center;
					gap: 8px;
					margin-bottom: 15px;
				}
				.logo-img {
					object-fit: contain;
					height: 44px;
					width: auto;
					aspect-ratio: 1492 / 678;
				}
				.logo-text {
					font-weight: 700;
					color: var(--text-primary);
				}
				.footer-tagline {
					font-size: 0.95rem;
					line-height: 1.6;
				}
				.footer-grid {
					display: flex;
					gap: 60px;
				}
				.footer-column h3 {
					color: var(--text-primary);
					margin-bottom: 20px;
					font-size: 1.1rem;
				}
				.footer-column ul {
					list-style: none;
				}
				.footer-column ul li {
					margin-bottom: 10px;
				}
				.footer-column ul li a:hover {
					color: var(--gold);
				}
				.footer-bottom {
					padding-top: 30px;
					border-top: 1px solid var(--border);
					text-align: center;
					font-size: 0.85rem;
				}
				@media (max-width: 600px) {
					.footer-grid {
						gap: 30px;
						width: 100%;
					}
				}
			`}</style>
		</footer>
	);
}

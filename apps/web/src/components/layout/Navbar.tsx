'use client';

import { Link } from '@/i18n/routing';
import Image from 'next/image';
import { useTranslations } from 'next-intl';
import LanguageSwitcher from '../common/LanguageSwitcher';

export default function Navbar() {
	const t = useTranslations('Navigation');

	return (
		<nav className='navbar'>
			<div className='container nav-content'>
				<Link href='/' className='logo'>
					<Image
						src='/logo.png'
						alt='Takwa Logo'
						width={140}
						height={60}
						className='logo-img'
					/>
				</Link>
				<div className='nav-links'>
					<Link href='/'>{t('home')}</Link>
					<Link href='/support'>{t('support')}</Link>
					<Link href='/privacy'>{t('privacy')}</Link>
					<Link href='/terms'>{t('terms')}</Link>
					<LanguageSwitcher />
					<Link
						href='https://supabase.com'
						target='_blank'
						className='btn-primary'
						style={{ padding: '8px 20px', fontSize: '0.9rem' }}>
						{t('download')}
					</Link>
				</div>
			</div>

			<style jsx>{`
				.navbar {
					height: 80px;
					display: flex;
					align-items: center;
					background: rgba(4, 1, 30, 0.8);
					backdrop-filter: blur(10px);
					position: sticky;
					top: 0;
					z-index: 1000;
					border-bottom: 1px solid var(--border);
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
					gap: 10px;
				}
				.logo-text {
					font-weight: 700;
					font-size: 1.2rem;
					letter-spacing: 1px;
				}
				.nav-links {
					display: flex;
					align-items: center;
					gap: 30px;
					font-weight: 500;
					color: var(--text-secondary);
				}
				.nav-links a:hover {
					color: var(--gold);
				}
				@media (max-width: 768px) {
					.nav-links {
						display: none;
					}
				}
			`}</style>
		</nav>
	);
}

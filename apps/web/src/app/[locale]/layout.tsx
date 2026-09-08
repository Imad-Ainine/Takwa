import type { Metadata, Viewport } from 'next';
import { Plus_Jakarta_Sans, Amiri } from 'next/font/google';
import '../globals.css';
import Navbar from '@/components/layout/Navbar';
import Footer from '@/components/layout/Footer';
import { NextIntlClientProvider } from 'next-intl';
import { getMessages, getTranslations } from 'next-intl/server';
import { notFound } from 'next/navigation';
import { routing } from '@/i18n/routing';

const plusJakartaSans = Plus_Jakarta_Sans({
	subsets: ['latin'],
	display: 'swap',
	variable: '--font-sans',
	weight: ['400', '500', '600', '700', '800'],
});

const amiri = Amiri({
	subsets: ['arabic', 'latin'],
	display: 'swap',
	variable: '--font-amiri',
	weight: ['400', '700'],
});

export async function generateMetadata({
	params,
}: {
	params: Promise<{ locale: string }>;
}): Promise<Metadata> {
	const { locale } = await params;
	const t = await getTranslations({ locale, namespace: 'Metadata' });

	return {
		metadataBase: new URL('http://localhost:3000'),
		title: t('title'),
		description: t('description'),
		keywords: [
			'Islamic app',
			'Takwa',
			'Prayer times',
			'Holy Quran',
			'Qibla direction',
			'Azkar',
			'Adhan notifications',
			'Ramadan 2026',
		],
		authors: [{ name: 'Takwa Team' }],
		openGraph: {
			title: t('title'),
			description: t('description'),
			url: 'https://takwa-app.com',
			siteName: 'Takwa',
			images: [
				{
					url: '/logo.png',
					width: 512,
					height: 512,
					alt: 'Takwa Logo',
				},
			],
			locale:
				locale === 'ar' ? 'ar_SA' : locale === 'fr' ? 'fr_FR' : 'en_US',
			type: 'website',
		},
		twitter: {
			card: 'summary_large_image',
			title: t('title'),
			description: t('description'),
			images: ['/logo.png'],
		},
		icons: {
			icon: [
				{ url: '/favicon.ico' },
				{ url: '/favicon-16x16.png', sizes: '16x16', type: 'image/png' },
				{ url: '/favicon-32x32.png', sizes: '32x32', type: 'image/png' },
			],
			shortcut: '/logo.png',
			apple: '/apple-touch-icon.png',
		},
	};
}

export const viewport: Viewport = {
	width: 'device-width',
	initialScale: 1,
	maximumScale: 1,
};

export default async function RootLayout({
	children,
	params,
}: {
	children: React.ReactNode;
	params: Promise<{ locale: string }>;
}) {
	const { locale } = await params;

	// Ensure that the incoming `locale` is valid
	if (!routing.locales.includes(locale as never)) {
		notFound();
	}

	// Providing all messages to the client
	// side is the easiest way to get started
	const messages = await getMessages();

	const direction = locale === 'ar' ? 'rtl' : 'ltr';

	return (
		<html
			lang={locale}
			dir={direction}
			data-scroll-behavior='smooth'
			suppressHydrationWarning>
			<body
				className={`${plusJakartaSans.variable} ${amiri.variable} ${locale === 'ar' ? 'amiri' : ''}`}
				suppressHydrationWarning>
				<NextIntlClientProvider messages={messages}>
					<Navbar />
					<div className="main-wrapper">{children}</div>
					<Footer />
				</NextIntlClientProvider>
			</body>
		</html>
	);
}

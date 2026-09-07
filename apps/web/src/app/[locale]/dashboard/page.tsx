import { getTranslations } from 'next-intl/server';
import { redirect } from '@/i18n/routing';
import { createClient } from '@/lib/supabase/server';
import { signOut } from './actions';
import styles from './dashboard.module.css';

/**
 * The Web Companion Dashboard roadmap item's foundation (engineering
 * audit §8): proves a signed-in Supabase session works end-to-end on the
 * server side of the web app — nothing here reads from the app's actual
 * data tables yet. That's the next, separate step once this foundation
 * is in place: the stats/achievements read-only views the roadmap
 * describes belong here, reading the same RLS-scoped tables mobile
 * already syncs (see the audit's §4 security pass).
 */
export default async function DashboardPage({
	params,
}: {
	params: Promise<{ locale: string }>;
}) {
	const { locale } = await params;
	const t = await getTranslations('Dashboard');

	const supabase = await createClient();
	const {
		data: { user },
	} = await supabase.auth.getUser();

	if (!user) {
		redirect({ href: '/login', locale });
	}

	return (
		<div className={styles.page}>
			<div className={styles.card}>
				<h1 className="amiri gold-text">{t('title')}</h1>
				<p className={styles.welcome}>{t('welcome', { email: user?.email ?? '' })}</p>
				<p className={styles.placeholderNote}>{t('placeholderNote')}</p>

				<form action={signOut}>
					<button type="submit" className="btn-outline">
						{t('signOut')}
					</button>
				</form>
			</div>
		</div>
	);
}

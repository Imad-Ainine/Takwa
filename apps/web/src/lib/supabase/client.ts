import { createBrowserClient } from '@supabase/ssr';

/**
 * Supabase client for use in Client Components. Reads the same
 * NEXT_PUBLIC_SUPABASE_URL / NEXT_PUBLIC_SUPABASE_ANON_KEY the server
 * client and proxy.ts use — see .env.local.example. The anon key is
 * meant to be public (it's already bundled into the compiled mobile app
 * the same way); every table it can touch is RLS-scoped server-side, not
 * secured by keeping this key secret.
 */
export function createClient() {
	return createBrowserClient(
		process.env.NEXT_PUBLIC_SUPABASE_URL!,
		process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
	);
}

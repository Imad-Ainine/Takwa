import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

/**
 * Refreshes the Supabase auth session for one request/response pair.
 * Split out of proxy.ts so it can be layered onto whatever response
 * next-intl's own middleware produced, rather than the two middlewares
 * fighting over which response wins — see proxy.ts for how they combine.
 *
 * Mirrors Supabase's own documented pattern for Next.js middleware
 * (https://supabase.com/docs/guides/auth/server-side/nextjs): write
 * refreshed cookies onto both the request (so this request's Server
 * Components see them) and the response (so the browser keeps them).
 */
export async function updateSession(
	request: NextRequest,
	response: NextResponse
) {
	const supabase = createServerClient(
		process.env.NEXT_PUBLIC_SUPABASE_URL!,
		process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
		{
			cookies: {
				getAll() {
					return request.cookies.getAll();
				},
				setAll(cookiesToSet) {
					cookiesToSet.forEach(({ name, value }) =>
						request.cookies.set(name, value)
					);
					cookiesToSet.forEach(({ name, value, options }) =>
						response.cookies.set(name, value, options)
					);
				},
			},
		}
	);

	// Do not remove: this is what actually triggers a token refresh when
	// the access token has expired. Reading the session without calling a
	// method that talks to Supabase (e.g. just decoding the JWT locally)
	// would silently skip the refresh.
	await supabase.auth.getUser();

	return response;
}

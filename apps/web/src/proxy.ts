import createMiddleware from 'next-intl/middleware';
import { routing } from './i18n/routing';

export default createMiddleware(routing);

export const config = {
	// Match all pathnames except for:
	// - API routes
	// - _next (Next.js internals)
	// - _vercel (Vercel internals)
	// - static files (e.g. /favicon.ico, /logo.png, etc.)
	matcher: ['/', '/(ar|en)/:path*', '/((?!api|_next|_vercel|.*\\..*).*)'],
};

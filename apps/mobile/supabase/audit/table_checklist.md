# RLS table checklist

Derived from [`apps/mobile/docs/schema.sql`](../../docs/schema.sql) (a column
listing only — it does not record RLS status, so every row below is
"unverified" until checked against the output of
[`check_rls_status.sql`](./check_rls_status.sql) in the Supabase dashboard).

How to use this: run `check_rls_status.sql` in the SQL editor, then go row by
row below and fill in the ✅/❌/⚠️ column. Anything not ✅ by the time you're
done is a real gap — an anon-key request can read or write that table more
broadly than intended.

## Per-user tables (should be scoped to `auth.uid()`)

| Table | Owner column | Column shape | RLS verified? |
|---|---|---|---|
| `daily_records` | `user_id` | part of primary key (not nullable) | ☐ |
| `custom_ibadah` | `user_id` | part of primary key (not nullable) | ☐ |
| `user_settings` | `user_id` | part of primary key (not nullable) | ☐ |
| `achievements` | `user_id` | **nullable**, not a key column | ☐ |
| `custom_ibadah_log` | `user_id` | **nullable**, not a key column | ☐ |
| `prohibitions_log` | `user_id` | **nullable**, not a key column | ☐ |
| `user_adhkar` | `user_id` | **nullable**, not a key column | ☐ |
| `user_duas` | `user_id` | **nullable**, not a key column | ☐ |
| `book_reading_progress` | `user_id` | not marked nullable or primary in docs (likely `NOT NULL`) — verify | ☐ |
| `reminders` | `user_id` | not marked nullable or primary in docs (likely `NOT NULL`) — verify | ☐ |
| `profiles` | `id` (is the user id) | primary key | ☐ |

**The five bolded rows are the priority.** A nullable, non-key `user_id`
means a row can exist with no owner at all, and a policy written as
`user_id = auth.uid()` treats that NULL row inconsistently depending on
exactly how the policy is phrased (Postgres's three-valued NULL logic — the
comparison itself evaluates to NULL, which reads as "deny" under `USING`,
but a `NOT (user_id = auth.uid())` NOT-based policy would flip that). Prefer
migrating these to `user_id uuid NOT NULL REFERENCES auth.users(id)` going
forward; in the meantime, a policy needs to explicitly decide what a NULL
owner means (most likely: nobody but the row's creator, verified at insert
time) rather than leaving Postgres's default NULL comparison behavior to
decide by accident.

## Public / reference tables (should be public-read, no write from the app)

| Table | Notes |
|---|---|
| `adhkar` | Static content bundled with the app — verify writes are blocked for the anon/authenticated role, not just reads allowed |
| `adhkar_categories` | Same |
| `asma_allah` | Same |
| `books` | Same |
| `douaa_categories` | Same |
| `douaa_content` | Same |

## Community / moderated tables (mixed: public read, scoped write)

| Table | Notes |
|---|---|
| `community_adhkar` | [supabase_service.dart](../../lib/core/supabase/supabase_service.dart) reads `.eq('approved', true)` client-side — that's a UI filter, **not** a security boundary. Confirm a policy actually blocks reading `approved = false` rows for anyone but the row's own `shared_by` (and blocks writing `approved` at all from the client — approval should only ever be settable server-side). Also confirm `likes` can't be set to an arbitrary value by the client (the app increments it via read-then-write; a malicious client could `update` it directly if the policy allows any authenticated write). |
| `community_duas` | Same shape as `community_adhkar`, same checks apply |

## Once you've filled this in

1. Fix whatever `check_rls_status.sql` shows as missing/wrong, directly in
   the Supabase dashboard.
2. Export the *resulting* schema so it's no longer only visible in the
   dashboard: `supabase login`, `supabase link --project-ref <your-ref>`,
   then `supabase db pull` from `apps/mobile/` — this writes a timestamped
   migration file into `apps/mobile/supabase/migrations/` capturing the
   live schema (including RLS policies) as SQL.
3. Commit that migration file. From here on, policy changes should go
   through a new migration (`supabase migration new <name>`) and a PR,
   not a one-off dashboard edit — see the root [README](../README.md).

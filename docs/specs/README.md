# Takwa — Feature/Fix Specs

Specs for three related pieces of work, requested together because they touch the same
subsystems (`core/notifications`, `features/settings`, `core/database`, `core/supabase`):

| Spec | Kind | Summary |
|---|---|---|
| [`settings-notifications-improvements.md`](./settings-notifications-improvements.md) | Improvement | Consolidate and clarify the Settings → Notifications preference surface (`UserPreferences`, `settings_screen.dart`, `adhan_notifications_settings_screen.dart`) |
| [`adhan-overlay-auto-open.md`](./adhan-overlay-auto-open.md) | Improvement / bug | Make the Adhan overlay screen reliably auto-open at prayer time in every app state (foreground, backgrounded, killed) |
| [`achievements-statistics-db-persistence-fix.md`](./achievements-statistics-db-persistence-fix.md) | Bug fix | Root-cause and fix daily stats / achievements appearing to "not save" — points/streaks reverting the day after they were logged |

Each spec is anchored to current file paths and line numbers so it can be handed to whoever
implements it (human or agent) without re-deriving the investigation. Format: problem statement →
root cause (where applicable) → requirements in EARS form → acceptance criteria → test plan.

None of these specs have been implemented yet — this commit adds the specs only.

# Decisions: Supabase Web Auth

## [2026-01-25] Credential Injection Method
**Decision:** Use `--dart-define` flags for web credentials  
**Rationale:** Follows spec pattern, no credential exposure in code, already implemented via String.fromEnvironment()

## [2026-01-25] OAuth Support
**Decision:** Skip OAuth implementation for now  
**Rationale:** OAuth providers (Google/Apple) not configured in Supabase dashboard - separate task

## [2026-01-25] Testing Approach
**Decision:** Manual browser testing only  
**Rationale:** No automated test infrastructure exists for auth flows

# SEC-01 — Candidate package (2026-11-18)
Status: PREPARED, NOT EXECUTED OR VALIDATED. Production unchanged.
Base GitHub commit: e2b5c99d3ab8b037d4217dc23656ed13fc15f081.
Only schema metadata was read; no personal records.

## Files
- sql/SEC-01-candidate.sql: fixed initial jugador role, empty search_path with qualified relations, revoked trigger-function EXECUTE, explicit column allowlists, own-row private profile access, verified organizer tournament policies.
- sql/SEC-01-rollback.sql: previous function definitions, policies and effective client table privileges; for isolated rehearsal only.
- tests/SEC-01-security.sql: synthetic fixtures, negative authorization and positive own-write checks, transaction rollback.
These are review scripts, NOT automatically discoverable migrations. Both change scripts deliberately end in ROLLBACK.

## Decisions blocking production
1. Candidate adopts organizer_id = auth user UUID, consistent with existing policies. No FK exists on the four inspected tables; semantic correctness remains unproven. Do not migrate until owner confirms identifier meaning and existing mappings are checked privately.
2. Candidate requires verificado=true for creation AND modification. Product approval required.
3. profiles and organizers SELECT becomes owner-only; authenticated player statistics remain readable as before. Public directory needs a separate approved projection. SELECT * across other users will stop working.
4. categoria/nivel self-edit is provisional; approve sports classification rules. Existing users' roles are NOT corrected automatically: trusted operator must review assignments before relying on them.
5. No admin bypass based on profiles.rol is introduced. Trusted server/service_role remains privileged; no public key is granted backend privileges.
6. Current statistics insertion is also unsafe, not just UPDATE; column allowlists cover both. Tournament owner and counters inscriptos/inscritos are not client-editable.

## Isolated testing and costs
Supabase list_branches returned [] on 2026-11-18. No branch was created.
Official pricing: default Micro branch compute starts at USD 0.01344/hour (~0.32256/day), plus applicable disk, egress and storage usage. Spend Cap does not cover branches, nor do Compute Credits apply. This is published pricing, not an account-specific quote.
https://supabase.com/docs/guides/platform/manage-your-usage/branching

Preferred no-hosted-service option: local Supabase with CLI and compatible runtime, schema-only baseline and synthetic users. Work environment discovery found supabase.ps1, but no docker or psql in PATH. No installs, retries or local SQL were attempted.
CLI v3 changed local defaults: inspect installed version and --help before selecting commands; do not use guessed remote/reset commands.
https://supabase.com/changelog/supabase-cli-v3
https://supabase.com/docs/guides/local-development/database-migrations

## Reproduction procedure (pending)
1. Provision approved isolated Supabase runtime. Record project ref/localhost port; explicitly exclude ajsejzkhrfbglwiihdpi. No production credentials in runner.
2. Restore schema-only baseline including dependencies, roles, RLS flags, grants, indexes, functions and auth triggers. No real users or rows. No migration history currently exists: a new cloud branch cannot be assumed schema-equivalent.
3. Compare baseline metadata to production snapshot privately; stop on drift or additional policies/grants. The JSON here is targeted evidence, NOT a full restore dump.
4. In a disposable copy of candidate only, replace final ROLLBACK with COMMIT after confirming isolated target and proposed business rules. Run with stop-on-error.
5. Run tests with psql ON_ERROR_STOP=1. Expected: all statements succeed, all denied operations caught as insufficient_privilege, end ROLLBACK removes fixtures.
6. Separately test real Auth signup and authenticated REST calls with synthetic accounts A/B: forged metadata admin/organizador still creates jugador; email trigger works; private B fields absent; own fields editable; each of four statistics blocked for INSERT/UPDATE/upsert; verificado and role edits blocked; unverified and cross-owner tournament writes denied; verified own writes succeed; owner transfer denied; revoke verification and ensure writes stop. Test anon and trusted backend. Never use service_role to simulate A/B.
7. Trigger-returning functions cannot ordinarily execute as regular RPC functions; EXECUTE grants are confirmed excessive privilege, not proof of successful RPC exploitation. Assert all four anon/authenticated function privilege combinations and trigger signup after revoke.
8. Rehearse rollback on isolated environment: explicitly commit the rollback copy, compare definitions, policies, grants and behavior against baseline, then reapply candidate and rerun tests.

## Rollback and production gate
Within a failed migration transaction: ROLLBACK. After commit: prefer a forward fix; restoring old ACL/policies reopens known vulnerabilities. Provided rollback restores effective grants for captured baseline, not a forensic ACL dump; retain full pre-change schema/ACL snapshot before deployment. No data rollback is included or needed for candidate DDL. Never reset production or revert users created since deployment.
Before production: approve business decisions, verify compatibility, pass SQL + Auth/REST + rollback tests, capture private backup and drift report, generate a proper migration using installed CLI, obtain explicit production approval, apply transactionally with monitoring. Check leaked-password protection availability separately; not changed here.

## Results
Documentation reviewed; targeted metadata read; static SQL review completed.
SQL syntax/runtime, RLS behavior, Auth integration and rollback: NOT RUN.
No CI workflow created or triggered; frontend lint/build would not validate this SQL.
No production DDL/DML, no personal data exports, no services/costs accepted.

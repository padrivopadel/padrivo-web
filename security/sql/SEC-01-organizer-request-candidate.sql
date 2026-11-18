-- SEC-01 / ORGANIZER-01: local-only candidate. Run AFTER SEC-01-migration.sql.
-- NOT validated against a clean baseline. Do NOT run against hosted Supabase.
-- Use psql -X -v ON_ERROR_STOP=1 -1 for atomic application.
-- Assumes organizers_read owner-only policy and prior ACL revocations from SEC-01.
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';

DO $$
BEGIN
  IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.organizers'::regclass) THEN
    RAISE EXCEPTION 'organizers RLS must be enabled';
  END IF;
  IF EXISTS (SELECT 1 FROM public.organizers WHERE user_id IS NOT NULL GROUP BY user_id HAVING count(*) > 1) THEN
    RAISE EXCEPTION 'Duplicate organizer user_id: reconcile before applying';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='organizers' AND policyname='organizers_request_own') THEN
    RAISE EXCEPTION 'organizers_request_own already exists: do not rerun';
  END IF;
  IF has_table_privilege('authenticated','public.organizers','INSERT')
    OR has_table_privilege('authenticated','public.organizers','UPDATE')
    OR has_column_privilege('authenticated','public.organizers','verificado','INSERT')
    OR has_column_privilege('authenticated','public.organizers','verificado','UPDATE') THEN
    RAISE EXCEPTION 'Existing broad organizer grants: apply SEC-01 ACL hardening first';
  END IF;
END $$;

-- One organizer request per user. Null user_id is never permitted by the insert policy.
CREATE UNIQUE INDEX organizers_user_id_unique_sec01
  ON public.organizers (user_id);

-- Explicit column allowlist; verified remains server-controlled, default false.
GRANT INSERT (user_id, nombre, telefono, descripcion)
  ON public.organizers TO authenticated;

CREATE POLICY organizers_request_own ON public.organizers
  FOR INSERT TO authenticated
  WITH CHECK (
    (SELECT auth.uid()) IS NOT NULL
    AND user_id = (SELECT auth.uid())
    AND verificado IS FALSE
  );

-- No UPDATE grant or UPDATE policy for the user. Approval/revocation only through
-- a trusted admin workflow (not implemented by this SQL).
DO $$
BEGIN
  IF has_column_privilege('authenticated','public.organizers','verificado','INSERT')
     OR has_column_privilege('authenticated','public.organizers','verificado','UPDATE') THEN
    RAISE EXCEPTION 'verified flag is client-writeable';
  END IF;
END $$;

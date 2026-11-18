-- DRAFT / NOT VALIDATED. Isolated database only. Default ROLLBACK.
-- Decisions: owner-only profiles; organizer_id = auth user UUID; verified organizers only.
-- Approval of these business decisions and baseline parity required before deployment.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin

  insert into public.profiles
  (
    id,
    nombre,
    apellido,
    telefono,
    ciudad,
    rol,
    email
  )

  values
  (
    new.id,
    coalesce(new.raw_user_meta_data->>'nombre',''),
    coalesce(new.raw_user_meta_data->>'apellido',''),
    coalesce(new.raw_user_meta_data->>'telefono',''),
    coalesce(new.raw_user_meta_data->>'ciudad',''),
    'jugador',
    new.email
  );

  return new;

end;
$function$
;
CREATE OR REPLACE FUNCTION public.set_profile_email()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
  IF NEW.email IS NULL THEN
    SELECT email INTO NEW.email FROM auth.users WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$function$
;
REVOKE EXECUTE ON FUNCTION public.handle_new_user(), public.set_profile_email() FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ON public.profiles, public.player_profiles, public.organizers, public.tournaments FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("id") ON public."organizers" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("user_id") ON public."organizers" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("nombre") ON public."organizers" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("telefono") ON public."organizers" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("descripcion") ON public."organizers" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("verificado") ON public."organizers" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("created_at") ON public."organizers" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("id") ON public."player_profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("user_id") ON public."player_profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("categoria") ON public."player_profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("nivel") ON public."player_profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("partidos") ON public."player_profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("victorias") ON public."player_profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("derrotas") ON public."player_profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("puntos_ranking") ON public."player_profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("created_at") ON public."player_profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("id") ON public."profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("nombre") ON public."profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("apellido") ON public."profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("telefono") ON public."profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("ciudad") ON public."profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("rol") ON public."profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("foto") ON public."profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("created_at") ON public."profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("email") ON public."profiles" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("id") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("organizer_id") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("nombre") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("descripcion") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("club") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("ciudad") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("fecha_inicio") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("fecha_fin") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("categoria") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("modalidad") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("cupos") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("inscriptos") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("estado") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("imagen") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("premios") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("created_at") ON public."tournaments" FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ("inscritos") ON public."tournaments" FROM PUBLIC, anon, authenticated;
-- Remove table grants AND any independently granted column privileges.
GRANT SELECT ON public.profiles, public.player_profiles, public.organizers, public.tournaments TO authenticated;
GRANT UPDATE (nombre, apellido, telefono, ciudad, foto) ON public.profiles TO authenticated;
GRANT INSERT (user_id, categoria, nivel) ON public.player_profiles TO authenticated;
GRANT UPDATE (categoria, nivel) ON public.player_profiles TO authenticated;
-- No client writes to organizers.verificado or profiles.rol.
-- Neither insert nor update can set statistics; backend remains responsible.
GRANT INSERT (organizer_id,nombre,descripcion,club,ciudad,fecha_inicio,fecha_fin,categoria,modalidad,cupos,estado,imagen,premios) ON public.tournaments TO authenticated;
GRANT UPDATE (nombre,descripcion,club,ciudad,fecha_inicio,fecha_fin,categoria,modalidad,cupos,estado,imagen,premios) ON public.tournaments TO authenticated;
DROP POLICY "organizers_read" ON public."organizers";
DROP POLICY "player_profiles_insert" ON public."player_profiles";
DROP POLICY "player_profiles_select" ON public."player_profiles";
DROP POLICY "player_profiles_update" ON public."player_profiles";
DROP POLICY "profiles_select" ON public."profiles";
DROP POLICY "profiles_update" ON public."profiles";
DROP POLICY "organizers_create_tournaments" ON public."tournaments";
DROP POLICY "organizers_update_tournaments" ON public."tournaments";
DROP POLICY "tournaments_public_read" ON public."tournaments";
CREATE POLICY profiles_select ON public.profiles FOR SELECT TO authenticated USING ((select auth.uid()) = id);
CREATE POLICY profiles_update ON public.profiles FOR UPDATE TO authenticated USING ((select auth.uid()) = id) WITH CHECK ((select auth.uid()) = id);
CREATE POLICY player_profiles_select ON public.player_profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY player_profiles_insert ON public.player_profiles FOR INSERT TO authenticated WITH CHECK ((select auth.uid()) = user_id);
CREATE POLICY player_profiles_update ON public.player_profiles FOR UPDATE TO authenticated USING ((select auth.uid()) = user_id) WITH CHECK ((select auth.uid()) = user_id);
CREATE POLICY organizers_read ON public.organizers FOR SELECT TO authenticated USING ((select auth.uid()) = user_id);
CREATE POLICY tournaments_public_read ON public.tournaments FOR SELECT TO authenticated USING (true);
CREATE POLICY organizers_create_tournaments ON public.tournaments FOR INSERT TO authenticated
WITH CHECK (organizer_id = (select auth.uid()) AND EXISTS (SELECT 1 FROM public.organizers o WHERE o.user_id = (select auth.uid()) AND o.verificado IS TRUE));
CREATE POLICY organizers_update_tournaments ON public.tournaments FOR UPDATE TO authenticated
USING (organizer_id = (select auth.uid()) AND EXISTS (SELECT 1 FROM public.organizers o WHERE o.user_id = (select auth.uid()) AND o.verificado IS TRUE))
WITH CHECK (organizer_id = (select auth.uid()) AND EXISTS (SELECT 1 FROM public.organizers o WHERE o.user_id = (select auth.uid()) AND o.verificado IS TRUE));
-- Existing RLS must already be enabled. Abort on drift.
DO $$ BEGIN
 IF EXISTS (SELECT 1 FROM pg_class WHERE oid IN ('public.profiles'::regclass,'public.player_profiles'::regclass,'public.organizers'::regclass,'public.tournaments'::regclass) AND NOT relrowsecurity) THEN
 RAISE EXCEPTION 'RLS disabled: baseline mismatch'; END IF;
 IF has_function_privilege('anon','public.handle_new_user()','EXECUTE') OR has_function_privilege('authenticated','public.handle_new_user()','EXECUTE')
 OR has_function_privilege('anon','public.set_profile_email()','EXECUTE') OR has_function_privilege('authenticated','public.set_profile_email()','EXECUTE') THEN
 RAISE EXCEPTION 'Inherited EXECUTE remains'; END IF;
END $$;
ROLLBACK; -- Deliberate: review draft must not persist changes.

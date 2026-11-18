-- ISOLATED REHEARSAL ONLY. Restores insecure previous behavior; never automatic.
BEGIN;
SET LOCAL lock_timeout = '5s';
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
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
    coalesce(new.raw_user_meta_data->>'rol','jugador'),
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
AS $function$
BEGIN
  IF NEW.email IS NULL THEN
    SELECT email INTO NEW.email FROM auth.users WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$function$
;
GRANT EXECUTE ON FUNCTION public.handle_new_user(), public.set_profile_email() TO PUBLIC, anon, authenticated;
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
GRANT INSERT ON public."profiles" TO "anon";
GRANT SELECT ON public."profiles" TO "anon";
GRANT UPDATE ON public."profiles" TO "anon";
GRANT DELETE ON public."profiles" TO "anon";
GRANT TRUNCATE ON public."profiles" TO "anon";
GRANT REFERENCES ON public."profiles" TO "anon";
GRANT TRIGGER ON public."profiles" TO "anon";
GRANT INSERT ON public."profiles" TO "authenticated";
GRANT SELECT ON public."profiles" TO "authenticated";
GRANT UPDATE ON public."profiles" TO "authenticated";
GRANT DELETE ON public."profiles" TO "authenticated";
GRANT TRUNCATE ON public."profiles" TO "authenticated";
GRANT REFERENCES ON public."profiles" TO "authenticated";
GRANT TRIGGER ON public."profiles" TO "authenticated";
GRANT INSERT ON public."player_profiles" TO "anon";
GRANT SELECT ON public."player_profiles" TO "anon";
GRANT UPDATE ON public."player_profiles" TO "anon";
GRANT DELETE ON public."player_profiles" TO "anon";
GRANT TRUNCATE ON public."player_profiles" TO "anon";
GRANT REFERENCES ON public."player_profiles" TO "anon";
GRANT TRIGGER ON public."player_profiles" TO "anon";
GRANT INSERT ON public."player_profiles" TO "authenticated";
GRANT SELECT ON public."player_profiles" TO "authenticated";
GRANT UPDATE ON public."player_profiles" TO "authenticated";
GRANT DELETE ON public."player_profiles" TO "authenticated";
GRANT TRUNCATE ON public."player_profiles" TO "authenticated";
GRANT REFERENCES ON public."player_profiles" TO "authenticated";
GRANT TRIGGER ON public."player_profiles" TO "authenticated";
GRANT INSERT ON public."tournaments" TO "anon";
GRANT SELECT ON public."tournaments" TO "anon";
GRANT UPDATE ON public."tournaments" TO "anon";
GRANT DELETE ON public."tournaments" TO "anon";
GRANT TRUNCATE ON public."tournaments" TO "anon";
GRANT REFERENCES ON public."tournaments" TO "anon";
GRANT TRIGGER ON public."tournaments" TO "anon";
GRANT INSERT ON public."tournaments" TO "authenticated";
GRANT SELECT ON public."tournaments" TO "authenticated";
GRANT UPDATE ON public."tournaments" TO "authenticated";
GRANT DELETE ON public."tournaments" TO "authenticated";
GRANT TRUNCATE ON public."tournaments" TO "authenticated";
GRANT REFERENCES ON public."tournaments" TO "authenticated";
GRANT TRIGGER ON public."tournaments" TO "authenticated";
GRANT INSERT ON public."organizers" TO "anon";
GRANT SELECT ON public."organizers" TO "anon";
GRANT UPDATE ON public."organizers" TO "anon";
GRANT DELETE ON public."organizers" TO "anon";
GRANT TRUNCATE ON public."organizers" TO "anon";
GRANT REFERENCES ON public."organizers" TO "anon";
GRANT TRIGGER ON public."organizers" TO "anon";
GRANT INSERT ON public."organizers" TO "authenticated";
GRANT SELECT ON public."organizers" TO "authenticated";
GRANT UPDATE ON public."organizers" TO "authenticated";
GRANT DELETE ON public."organizers" TO "authenticated";
GRANT TRUNCATE ON public."organizers" TO "authenticated";
GRANT REFERENCES ON public."organizers" TO "authenticated";
GRANT TRIGGER ON public."organizers" TO "authenticated";
DROP POLICY "organizers_read" ON public."organizers";
DROP POLICY "player_profiles_insert" ON public."player_profiles";
DROP POLICY "player_profiles_select" ON public."player_profiles";
DROP POLICY "player_profiles_update" ON public."player_profiles";
DROP POLICY "profiles_select" ON public."profiles";
DROP POLICY "profiles_update" ON public."profiles";
DROP POLICY "organizers_create_tournaments" ON public."tournaments";
DROP POLICY "organizers_update_tournaments" ON public."tournaments";
DROP POLICY "tournaments_public_read" ON public."tournaments";
CREATE POLICY "organizers_read" ON public."organizers" AS PERMISSIVE FOR SELECT TO "authenticated" USING (true);
CREATE POLICY "player_profiles_insert" ON public."player_profiles" AS PERMISSIVE FOR INSERT TO "authenticated" WITH CHECK ((auth.uid() = user_id));
CREATE POLICY "player_profiles_select" ON public."player_profiles" AS PERMISSIVE FOR SELECT TO "authenticated" USING (true);
CREATE POLICY "player_profiles_update" ON public."player_profiles" AS PERMISSIVE FOR UPDATE TO "authenticated" USING ((auth.uid() = user_id));
CREATE POLICY "profiles_select" ON public."profiles" AS PERMISSIVE FOR SELECT TO "authenticated" USING (true);
CREATE POLICY "profiles_update" ON public."profiles" AS PERMISSIVE FOR UPDATE TO "authenticated" USING ((auth.uid() = id));
CREATE POLICY "organizers_create_tournaments" ON public."tournaments" AS PERMISSIVE FOR INSERT TO "authenticated" WITH CHECK ((auth.uid() = organizer_id));
CREATE POLICY "organizers_update_tournaments" ON public."tournaments" AS PERMISSIVE FOR UPDATE TO "authenticated" USING ((auth.uid() = organizer_id));
CREATE POLICY "tournaments_public_read" ON public."tournaments" AS PERMISSIVE FOR SELECT TO "authenticated" USING (true);
ROLLBACK; -- Confirm isolated target and explicit approval before changing to COMMIT.

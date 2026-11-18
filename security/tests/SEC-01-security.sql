-- Run ONLY after applying candidate to an isolated schema-equivalent Supabase.
-- Synthetic users only. Any error must fail runner (psql -v ON_ERROR_STOP=1).
BEGIN;
INSERT INTO auth.users (id,email,raw_user_meta_data) VALUES
('00000000-0000-4000-8000-000000000001','sec01-a@example.invalid','{"rol":"admin","nombre":"SEC01 A"}'),
('00000000-0000-4000-8000-000000000002','sec01-b@example.invalid','{"nombre":"SEC01 B"}');
DO $$ BEGIN
 IF (SELECT count(*) FROM public.profiles WHERE id IN ('00000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000002') AND rol='jugador') <> 2 THEN RAISE EXCEPTION 'unsafe initial role'; END IF;
 IF has_column_privilege('authenticated','public.profiles','rol','UPDATE') OR has_column_privilege('authenticated','public.player_profiles','puntos_ranking','INSERT') OR has_column_privilege('authenticated','public.player_profiles','victorias','UPDATE') OR has_column_privilege('authenticated','public.organizers','verificado','UPDATE') THEN RAISE EXCEPTION 'protected column writable'; END IF;
END $$;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000001',true);
SELECT set_config('request.jwt.claims','{"sub":"00000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
DO $$ DECLARE n integer; BEGIN
 IF EXISTS(SELECT 1 FROM public.profiles WHERE id='00000000-0000-4000-8000-000000000002') THEN RAISE EXCEPTION 'profile B exposed'; END IF;
 UPDATE public.profiles SET nombre='SEC01 edited' WHERE id='00000000-0000-4000-8000-000000000001';
 GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'own edit broken'; END IF;
 UPDATE public.profiles SET nombre='forbidden' WHERE id='00000000-0000-4000-8000-000000000002';
 GET DIAGNOSTICS n=ROW_COUNT; IF n<>0 THEN RAISE EXCEPTION 'cross edit allowed'; END IF;
 BEGIN UPDATE public.profiles SET rol='admin' WHERE id=auth.uid(); RAISE EXCEPTION 'role edit allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN INSERT INTO public.player_profiles(user_id,puntos_ranking) VALUES(auth.uid(),999); RAISE EXCEPTION 'stats injection allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 INSERT INTO public.player_profiles(user_id,categoria,nivel) VALUES(auth.uid(),'test','test');
 BEGIN UPDATE public.player_profiles SET victorias=999 WHERE user_id=auth.uid(); RAISE EXCEPTION 'stats update allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN INSERT INTO public.tournaments(organizer_id,nombre) VALUES(auth.uid(),'forbidden'); RAISE EXCEPTION 'unverified tournament allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
INSERT INTO public.organizers(user_id,verificado) VALUES('00000000-0000-4000-8000-000000000001',true);
INSERT INTO public.tournaments(id,organizer_id,nombre) VALUES('00000000-0000-4000-8000-000000000010','00000000-0000-4000-8000-000000000002','B tournament');
SET LOCAL ROLE authenticated;
DO $$ DECLARE n integer; BEGIN
 INSERT INTO public.tournaments(organizer_id,nombre) VALUES(auth.uid(),'A tournament');
 UPDATE public.tournaments SET nombre='A edited' WHERE organizer_id=auth.uid();
 GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'verified own update broken'; END IF;
 UPDATE public.tournaments SET nombre='forbidden' WHERE id='00000000-0000-4000-8000-000000000010';
 GET DIAGNOSTICS n=ROW_COUNT; IF n<>0 THEN RAISE EXCEPTION 'cross tournament edit allowed'; END IF;
 BEGIN UPDATE public.tournaments SET organizer_id='00000000-0000-4000-8000-000000000002' WHERE organizer_id=auth.uid(); RAISE EXCEPTION 'owner transfer allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
SET LOCAL ROLE anon;
DO $$ BEGIN
 BEGIN PERFORM email FROM public.profiles; RAISE EXCEPTION 'anonymous read allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
DO $$ BEGIN
 IF has_function_privilege('anon','public.handle_new_user()','EXECUTE') OR has_function_privilege('authenticated','public.set_profile_email()','EXECUTE') THEN RAISE EXCEPTION 'function exposed'; END IF;
END $$;
ROLLBACK;

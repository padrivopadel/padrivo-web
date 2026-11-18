-- ADMIN-01 V2: pruebas RLS de torneos.
-- Ejecutar despues de ADMIN-01-migration-v2.sql.
-- Requiere BEGIN/ROLLBACK externos.

-- Crear usuarios temporales.
INSERT INTO auth.users (
    id, instance_id, aud, role, email,
    encrypted_password, raw_user_meta_data
)
VALUES
(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'admin-torneos@example.invalid',
    '',
    '{}'::jsonb
),
(
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'organizador-torneos@example.invalid',
    '',
    '{}'::jsonb
);

INSERT INTO public.admin_users (user_id)
VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');

INSERT INTO public.organizers (
    id, user_id, nombre
)
VALUES (
    'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    'Organizador torneos RLS'
);

-- 1. Organizador pendiente: INSERT debe fallar.
SET LOCAL ROLE authenticated;

SELECT set_config(
    'request.jwt.claim.sub',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    true
);

DO $$
DECLARE
    v_bloqueado boolean := false;
BEGIN
    BEGIN
        INSERT INTO public.tournaments (
            organizer_id, nombre
        )
        VALUES (
            'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
            'Torneo pendiente prohibido'
        );

    EXCEPTION WHEN insufficient_privilege
        OR check_violation THEN
        v_bloqueado := true;
    END;

    IF NOT v_bloqueado THEN
        RAISE EXCEPTION
            'FALLO: organizador pendiente pudo crear torneo';
    END IF;

    RAISE NOTICE
        'ADMIN-01: organizador pendiente bloqueado';
END;
$$;

RESET ROLE;

-- 2. Aprobar al organizador.
SET LOCAL ROLE authenticated;

SELECT set_config(
    'request.jwt.claim.sub',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    true
);

SELECT public.admin_decidir_organizador(
    'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
    'aprobar',
    'Aprobacion para prueba RLS'
);

RESET ROLE;

-- 3. Organizador aprobado: INSERT permitido.
SET LOCAL ROLE authenticated;

SELECT set_config(
    'request.jwt.claim.sub',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    true
);

INSERT INTO public.tournaments (
    organizer_id, nombre
)
VALUES (
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    'Torneo aprobado permitido'
);

RESET ROLE;

-- 4. Verificar que solo se creo el torneo autorizado.
DO $$
BEGIN
    IF (
        SELECT count(*)
        FROM public.tournaments
        WHERE organizer_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
          AND nombre = 'Torneo aprobado permitido'
    ) <> 1 THEN
        RAISE EXCEPTION
            'FALLO: torneo aprobado no fue creado';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM public.tournaments
        WHERE nombre = 'Torneo pendiente prohibido'
    ) THEN
        RAISE EXCEPTION
            'FALLO: torneo pendiente fue insertado';
    END IF;

    RAISE NOTICE
        'ADMIN-01 V2: RLS de creacion de torneos correcto';
END;
$$;
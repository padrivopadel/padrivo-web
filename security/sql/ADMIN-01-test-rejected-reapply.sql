-- ADMIN-01 V2: rechazo seguido de nueva solicitud.
-- Ejecutar despues de la migracion, dentro de BEGIN/ROLLBACK.
-- No ejecutar junto a test-approved.sql.

-- 1. Crear usuarios temporales.
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
    'admin-rechazo@example.invalid',
    '',
    '{}'::jsonb
),
(
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'organizador-rechazo@example.invalid',
    '',
    '{}'::jsonb
);

-- 2. Registrar administrador y solicitud inicial.
INSERT INTO public.admin_users (user_id)
VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');

INSERT INTO public.organizers (
    id, user_id, nombre
)
VALUES (
    'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    'Solicitud inicial para rechazo'
);

-- 3. Rechazar como administrador.
SET LOCAL ROLE authenticated;

SELECT set_config(
    'request.jwt.claim.sub',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    true
);

SELECT public.admin_decidir_organizador(
    'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
    'rechazar',
    'Motivo de prueba'
);

RESET ROLE;

-- 4. Verificar rechazo y auditoria.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM public.organizers
        WHERE id = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'
          AND estado = 'rechazado'
          AND verificado IS FALSE
    ) THEN
        RAISE EXCEPTION 'FALLO: rechazo incorrecto';
    END IF;

    IF (
        SELECT count(*)
        FROM public.organizer_audit_log
        WHERE organizer_id = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'
          AND accion = 'rechazar'
          AND admin_user_id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'
    ) <> 1 THEN
        RAISE EXCEPTION 'FALLO: auditoria de rechazo incorrecta';
    END IF;

    RAISE NOTICE 'ADMIN-01 V2: rechazo y auditoria correctos';
END;
$$;

-- 5. Nueva solicitud como usuario autenticado.
SET LOCAL ROLE authenticated;

SELECT set_config(
    'request.jwt.claim.sub',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    true
);

INSERT INTO public.organizers (
    user_id, nombre
)
VALUES (
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    'Nueva solicitud tras rechazo'
);

RESET ROLE;

-- 6. Verificar historial y nueva solicitud.
DO $$
BEGIN
    IF (
        SELECT count(*)
        FROM public.organizers
        WHERE user_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
    ) <> 2 THEN
        RAISE EXCEPTION 'FALLO: historial incorrecto';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM public.organizers
        WHERE user_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
          AND nombre = 'Nueva solicitud tras rechazo'
          AND estado = 'pendiente'
          AND verificado IS FALSE
          AND id <> 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'
    ) THEN
        RAISE EXCEPTION 'FALLO: nueva solicitud incorrecta';
    END IF;

    IF (
        SELECT count(*)
        FROM public.organizers
        WHERE user_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
          AND estado IN ('pendiente', 'aprobado')
    ) <> 1 THEN
        RAISE EXCEPTION 'FALLO: cantidad de solicitudes activas';
    END IF;

    RAISE NOTICE 'ADMIN-01 V2: rechazo, nueva solicitud e historial correctos';
END;
$$;
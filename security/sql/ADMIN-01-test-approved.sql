-- ADMIN-01: Prueba positiva de aprobacion
-- Ejecutar despues de la migracion, dentro de BEGIN/ROLLBACK.

-- Crear dos usuarios temporales.
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
    'admin-test-padrivo@example.invalid',
    '',
    '{"nombre":"Admin temporal"}'::jsonb
),
(
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'organizador-test-padrivo@example.invalid',
    '',
    '{"nombre":"Organizador temporal"}'::jsonb
);

-- Registrar al administrador autorizado.
INSERT INTO public.admin_users (user_id)
VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');

-- Crear una solicitud pendiente.
INSERT INTO public.organizers (
    id, user_id, nombre, verificado
)
VALUES (
    'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    'Organizador de prueba',
    false
);

-- Simular la sesion del administrador.
SET LOCAL ROLE authenticated;

SELECT set_config(
    'request.jwt.claim.sub',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    true
);

-- Ejecutar la aprobacion.
SELECT public.admin_decidir_organizador(
    'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
    'aprobar',
    'Aprobacion de prueba local'
);

-- Recuperar el rol original para verificar los resultados.
-- La aprobacion anterior se ejecuto como authenticated.
RESET ROLE;

-- Verificar estado y auditoria.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM public.organizers
        WHERE id = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'
          AND estado = 'aprobado'
          AND verificado IS TRUE
    ) THEN
        RAISE EXCEPTION 'Fallo: organizador no aprobado';
    END IF;

    IF (
        SELECT count(*)
        FROM public.organizer_audit_log
        WHERE organizer_id = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'
          AND admin_user_id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'
          AND accion = 'aprobar'
          AND motivo = 'Aprobacion de prueba local'
    ) <> 1 THEN
        RAISE EXCEPTION 'Fallo: auditoria incorrecta';
    END IF;

    RAISE NOTICE 'ADMIN-01: aprobacion y auditoria correctas';
END;
$$;
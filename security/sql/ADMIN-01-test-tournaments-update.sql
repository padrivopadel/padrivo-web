-- ADMIN-01 V2: UPDATE, propiedad y revocacion.
-- Ejecutar despues de ADMIN-01-test-tournaments-rls.sql.
-- Requiere BEGIN/ROLLBACK externos.

-- Crear un torneo ajeno como postgres, solo para pruebas.
INSERT INTO public.tournaments (
    organizer_id, nombre
)
VALUES (
    '11111111-1111-4111-8111-111111111111',
    'Torneo ajeno de prueba'
);

-- Organizador aprobado.
SET LOCAL ROLE authenticated;

SELECT set_config(
    'request.jwt.claim.sub',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    true
);

-- 1. Actualizar torneo propio.
DO $$
DECLARE
    v_filas bigint;
BEGIN
    UPDATE public.tournaments
    SET nombre = 'Torneo propio actualizado'
    WHERE organizer_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
      AND nombre = 'Torneo aprobado permitido';

    GET DIAGNOSTICS v_filas = ROW_COUNT;

    IF v_filas <> 1 THEN
        RAISE EXCEPTION
            'FALLO: UPDATE propio afecto % filas; esperado 1',
            v_filas;
    END IF;

    RAISE NOTICE
        'ADMIN-01 V2: UPDATE propio afecto exactamente 1 fila';
END;
$$;

-- 2. Intentar actualizar torneo ajeno.
DO $$
DECLARE
    v_filas bigint;
BEGIN
    UPDATE public.tournaments
    SET nombre = 'Modificacion indebida'
    WHERE organizer_id = '11111111-1111-4111-8111-111111111111'
      AND nombre = 'Torneo ajeno de prueba';

    GET DIAGNOSTICS v_filas = ROW_COUNT;

    IF v_filas <> 0 THEN
        RAISE EXCEPTION
            'FALLO: UPDATE ajeno afecto % filas; esperado 0',
            v_filas;
    END IF;

    RAISE NOTICE
        'ADMIN-01 V2: UPDATE ajeno afecto exactamente 0 filas';
END;
$$;

-- 3. Intentar cambiar organizer_id.
DO $$
DECLARE
    v_bloqueado boolean := false;
BEGIN
    BEGIN
        UPDATE public.tournaments
        SET organizer_id = '11111111-1111-4111-8111-111111111111'
        WHERE nombre = 'Torneo propio actualizado';

    EXCEPTION WHEN insufficient_privilege THEN
        v_bloqueado := true;
    END;

    IF NOT v_bloqueado THEN
        RAISE EXCEPTION
            'FALLO: se permitio modificar organizer_id';
    END IF;

    RAISE NOTICE
        'ADMIN-01 V2: cambio de propietario bloqueado';
END;
$$;

RESET ROLE;

-- Verificar resultados como postgres.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM public.tournaments
        WHERE organizer_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
          AND nombre = 'Torneo propio actualizado'
    ) THEN
        RAISE EXCEPTION
            'FALLO: actualizacion de torneo propio';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM public.tournaments
        WHERE organizer_id = '11111111-1111-4111-8111-111111111111'
          AND nombre = 'Torneo ajeno de prueba'
    ) THEN
        RAISE EXCEPTION
            'FALLO: torneo ajeno modificado';
    END IF;

    RAISE NOTICE
        'ADMIN-01 V2: actualizacion propia y aislamiento correctos';
END;
$$;

-- 4. Revocar al organizador.
SET LOCAL ROLE authenticated;

SELECT set_config(
    'request.jwt.claim.sub',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    true
);

SELECT public.admin_decidir_organizador(
    'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
    'revocar',
    'Revocacion para prueba RLS'
);

RESET ROLE;

-- 5. Intentar crear torneo estando revocado.
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
            'Torneo revocado prohibido'
        );

    EXCEPTION WHEN insufficient_privilege
        OR check_violation THEN
        v_bloqueado := true;
    END;

    IF NOT v_bloqueado THEN
        RAISE EXCEPTION
            'FALLO: organizador revocado pudo crear torneo';
    END IF;

    RAISE NOTICE
        'ADMIN-01 V2: creacion tras revocacion bloqueada';
END;
$$;

-- 6. Intentar actualizar torneo estando revocado.
DO $$
DECLARE
    v_filas bigint;
BEGIN
    UPDATE public.tournaments
    SET nombre = 'Actualizacion revocada prohibida'
    WHERE organizer_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
      AND nombre = 'Torneo propio actualizado';

    GET DIAGNOSTICS v_filas = ROW_COUNT;

    IF v_filas <> 0 THEN
        RAISE EXCEPTION
            'FALLO: UPDATE revocado afecto % filas; esperado 0',
            v_filas;
    END IF;

    RAISE NOTICE
        'ADMIN-01 V2: UPDATE revocado afecto exactamente 0 filas';
END;
$$;

RESET ROLE;

-- 7. Verificar que la revocacion impidio cambios.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM public.tournaments
        WHERE organizer_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
          AND nombre = 'Torneo propio actualizado'
    ) THEN
        RAISE EXCEPTION
            'FALLO: organizador revocado modifico torneo';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM public.tournaments
        WHERE nombre IN (
            'Torneo revocado prohibido',
            'Actualizacion revocada prohibida',
            'Modificacion indebida'
        )
    ) THEN
        RAISE EXCEPTION
            'FALLO: operacion no autorizada persistida';
    END IF;

    RAISE NOTICE
        'ADMIN-01 V2: revocacion y RLS correctos';
END;
$$;
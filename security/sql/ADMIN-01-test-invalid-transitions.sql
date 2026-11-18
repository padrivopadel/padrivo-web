-- ADMIN-01: Pruebas de transiciones invalidas
-- Requiere ejecutar previamente ADMIN-01-test-approved.sql
-- dentro de la misma transaccion.

SET LOCAL ROLE authenticated;

SELECT set_config(
    'request.jwt.claim.sub',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    true
);

DO $$
DECLARE
    v_rechazada boolean;
BEGIN

    -- PRUEBA 1: Aprobar nuevamente un organizador aprobado.
    v_rechazada := false;

    BEGIN
        PERFORM public.admin_decidir_organizador(
            'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
            'aprobar',
            'Prueba de transicion invalida'
        );
    EXCEPTION WHEN raise_exception THEN
        IF SQLERRM = 'Transicion de estado no permitida' THEN
            v_rechazada := true;
        ELSE
            RAISE;
        END IF;
    END;

    IF NOT v_rechazada THEN
        RAISE EXCEPTION 'FALLO: se permitio aprobar nuevamente';
    END IF;

    -- PRUEBA 2: Rechazar un organizador ya aprobado.
    v_rechazada := false;

    BEGIN
        PERFORM public.admin_decidir_organizador(
            'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
            'rechazar',
            'Prueba de transicion invalida'
        );
    EXCEPTION WHEN raise_exception THEN
        IF SQLERRM = 'Transicion de estado no permitida' THEN
            v_rechazada := true;
        ELSE
            RAISE;
        END IF;
    END;

    IF NOT v_rechazada THEN
        RAISE EXCEPTION 'FALLO: se permitio rechazar un aprobado';
    END IF;

    -- PRUEBA 3: Revocar un organizador aprobado.
    PERFORM public.admin_decidir_organizador(
        'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
        'revocar',
        'Revocacion de prueba local'
    );

    -- PRUEBA 4: Aprobar directamente un organizador revocado.
    v_rechazada := false;

    BEGIN
        PERFORM public.admin_decidir_organizador(
            'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
            'aprobar',
            'Prueba de reactivacion invalida'
        );
    EXCEPTION WHEN raise_exception THEN
        IF SQLERRM = 'Transicion de estado no permitida' THEN
            v_rechazada := true;
        ELSE
            RAISE;
        END IF;
    END;

    IF NOT v_rechazada THEN
        RAISE EXCEPTION 'FALLO: se permitio aprobar un revocado';
    END IF;

    RAISE NOTICE 'ADMIN-01: transiciones ejecutadas correctamente';

END;
$$;

RESET ROLE;

-- Verificacion final como postgres.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM public.organizers
        WHERE id = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'
          AND estado = 'revocado'
          AND verificado IS FALSE
    ) THEN
        RAISE EXCEPTION 'FALLO: estado final incorrecto';
    END IF;

    IF (
        SELECT count(*)
        FROM public.organizer_audit_log
        WHERE organizer_id = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'
    ) <> 2 THEN
        RAISE EXCEPTION 'FALLO: cantidad de auditorias incorrecta';
    END IF;

    RAISE NOTICE 'ADMIN-01: transiciones y auditoria correctas';
END;
$$;
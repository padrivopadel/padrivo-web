-- ADMIN-01 V2: impedir solicitudes activas duplicadas.
-- Ejecutar despues de ADMIN-01-test-reapply.sql
-- dentro de una transaccion con ROLLBACK.

SET LOCAL ROLE authenticated;

SELECT set_config(
    'request.jwt.claim.sub',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    true
);

DO $$
DECLARE
    v_rechazada boolean := false;
BEGIN
    BEGIN
        INSERT INTO public.organizers (
            user_id, nombre
        )
        VALUES (
            'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
            'Solicitud duplicada'
        );

    EXCEPTION WHEN unique_violation THEN
        v_rechazada := true;
    END;

    IF NOT v_rechazada THEN
        RAISE EXCEPTION
            'FALLO: se permitio una solicitud activa duplicada';
    END IF;

    RAISE NOTICE
        'ADMIN-01 V2: solicitud duplicada bloqueada';
END;
$$;

RESET ROLE;

DO $$
BEGIN
    IF (
        SELECT count(*)
        FROM public.organizers
        WHERE user_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
    ) <> 2 THEN
        RAISE EXCEPTION
            'FALLO: cantidad de solicitudes incorrecta';
    END IF;

    RAISE NOTICE
        'ADMIN-01 V2: historial intacto tras duplicado';
END;
$$;
-- ADMIN-01 V2: historial y nuevas solicitudes.
-- Requiere ejecutar previamente:
-- 1. ADMIN-01-migration-v2.sql
-- 2. ADMIN-01-test-approved.sql
-- 3. ADMIN-01-test-invalid-transitions.sql
-- Todo dentro de la misma transaccion con ROLLBACK.

-- La solicitud original debe estar revocada.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM public.organizers
        WHERE id = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'
          AND estado = 'revocado'
          AND verificado IS FALSE
    ) THEN
        RAISE EXCEPTION 'FALLO: falta solicitud revocada';
    END IF;
END;
$$;

-- Simular al usuario organizador.
SET LOCAL ROLE authenticated;

SELECT set_config(
    'request.jwt.claim.sub',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    true
);

-- Nueva solicitud tras revocacion.
INSERT INTO public.organizers (
    user_id, nombre
)
VALUES (
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    'Nueva solicitud de prueba'
);

RESET ROLE;

-- Comprobar historial y estados.
DO $$
BEGIN
    IF (
        SELECT count(*)
        FROM public.organizers
        WHERE user_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
    ) <> 2 THEN
        RAISE EXCEPTION 'FALLO: historial incompleto';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM public.organizers
        WHERE nombre = 'Nueva solicitud de prueba'
          AND estado = 'pendiente'
          AND verificado IS FALSE
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

    IF (
        SELECT count(*)
        FROM public.organizer_audit_log
        WHERE organizer_id = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'
    ) <> 2 THEN
        RAISE EXCEPTION 'FALLO: auditoria historica incorrecta';
    END IF;

    RAISE NOTICE 'ADMIN-01 V2: nueva solicitud e historial correctos';
END;
$$;
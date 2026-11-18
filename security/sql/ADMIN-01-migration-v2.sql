-- ============================================================
-- PADRIVO PADEL
-- ADMIN-01 / MIGRATION V2
-- CANDIDATO LOCAL - NO EJECUTAR EN PRODUCCION
-- ============================================================
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';

-- ------------------------------------------------------------
-- 1. VALIDACIONES PREVIAS
-- ------------------------------------------------------------

DO $$
BEGIN
    IF NOT (
        SELECT relrowsecurity
        FROM pg_class
        WHERE oid = 'public.organizers'::regclass
    ) THEN
        RAISE EXCEPTION 'RLS debe estar habilitado';
    END IF;

    IF EXISTS (SELECT 1 FROM public.organizers) THEN
        RAISE EXCEPTION
            'Existen organizadores. Requiere reconciliacion previa';
    END IF;

    IF to_regclass(
        'public.organizers_user_id_unique_sec01'
    ) IS NULL THEN
        RAISE EXCEPTION 'No se encontro el indice esperado';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'organizers'
          AND policyname = 'organizers_request_own'
    ) THEN
        RAISE EXCEPTION 'No se encontro la politica de solicitudes';
    END IF;
END;
$$;

-- ------------------------------------------------------------
-- 2. ADMINISTRADORES AUTORIZADOS
-- ------------------------------------------------------------

CREATE TABLE public.admin_users (
    user_id uuid PRIMARY KEY
        REFERENCES auth.users(id)
        ON DELETE RESTRICT,

    created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.admin_users
ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.admin_users
FROM PUBLIC, anon, authenticated, service_role;

-- Los administradores se registraran mediante
-- un procedimiento privilegiado y controlado.
-- No se incorporan administradores automaticamente.

-- ------------------------------------------------------------
-- 3. ESTADOS DE SOLICITUDES
-- ------------------------------------------------------------

ALTER TABLE public.organizers
ADD COLUMN estado text NOT NULL DEFAULT 'pendiente';

ALTER TABLE public.organizers
ALTER COLUMN verificado SET DEFAULT false;

ALTER TABLE public.organizers
ALTER COLUMN verificado SET NOT NULL;

ALTER TABLE public.organizers
ADD CONSTRAINT organizers_estado_check
CHECK (
    estado IN (
        'pendiente',
        'aprobado',
        'rechazado',
        'revocado'
    )
);

ALTER TABLE public.organizers
ADD CONSTRAINT organizers_estado_verificado_check
CHECK (
    (estado = 'aprobado' AND verificado IS TRUE)
    OR
    (estado <> 'aprobado' AND verificado IS FALSE)
);

-- ------------------------------------------------------------
-- 4. SOLICITUDES HISTORICAS
-- ------------------------------------------------------------

DROP INDEX public.organizers_user_id_unique_sec01;

CREATE UNIQUE INDEX organizers_user_active_unique
ON public.organizers (user_id)
WHERE estado IN ('pendiente', 'aprobado');

-- ------------------------------------------------------------
-- 5. PROTECCION DE COLUMNAS ADMINISTRATIVAS
-- ------------------------------------------------------------

REVOKE INSERT (estado, verificado),
       UPDATE (estado, verificado, user_id)
ON TABLE public.organizers
FROM PUBLIC, anon, authenticated;

GRANT INSERT (user_id, nombre, telefono, descripcion)
ON TABLE public.organizers
TO authenticated;

-- ------------------------------------------------------------
-- 6. POLITICA DE NUEVAS SOLICITUDES
-- ------------------------------------------------------------

DROP POLICY organizers_request_own
ON public.organizers;

CREATE POLICY organizers_request_own
ON public.organizers
FOR INSERT
TO authenticated
WITH CHECK (
    (SELECT auth.uid()) IS NOT NULL
    AND user_id = (SELECT auth.uid())
    AND verificado IS FALSE
    AND estado = 'pendiente'
);

-- La politica organizers_read se conserva.
-- Los usuarios pueden consultar su propio historial.

-- ------------------------------------------------------------
-- 7. AUDITORIA ADMINISTRATIVA
-- ------------------------------------------------------------

CREATE TABLE public.organizer_audit_log (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    admin_user_id uuid NOT NULL
        REFERENCES public.admin_users(user_id)
        ON DELETE RESTRICT,

    organizer_id uuid NOT NULL
        REFERENCES public.organizers(id)
        ON DELETE RESTRICT,

    accion text NOT NULL
        CHECK (
            accion IN ('aprobar', 'rechazar', 'revocar')
        ),

    motivo text NOT NULL
        CHECK (length(btrim(motivo)) > 0),

    created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.organizer_audit_log
ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.organizer_audit_log
FROM PUBLIC, anon, authenticated, service_role;

-- ------------------------------------------------------------
-- 9. FUNCION ADMINISTRATIVA
-- ------------------------------------------------------------

CREATE FUNCTION public.admin_decidir_organizador(
    p_organizer_id uuid,
    p_accion text,
    p_motivo text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_admin_id uuid;
    v_estado_actual text;
    v_estado_nuevo text;
BEGIN

    v_admin_id := auth.uid();

    IF v_admin_id IS NULL OR NOT EXISTS (
        SELECT 1
        FROM public.admin_users
        WHERE user_id = v_admin_id
    ) THEN
        RAISE EXCEPTION 'Operacion no autorizada';
    END IF;

    IF p_organizer_id IS NULL
       OR p_accion IS NULL
       OR p_motivo IS NULL
       OR length(btrim(p_motivo)) = 0 THEN
        RAISE EXCEPTION 'Datos de decision invalidos';
    END IF;

    SELECT estado
    INTO v_estado_actual
    FROM public.organizers
    WHERE id = p_organizer_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Solicitud no encontrada';
    END IF;

    IF p_accion = 'aprobar'
       AND v_estado_actual = 'pendiente' THEN

        v_estado_nuevo := 'aprobado';

    ELSIF p_accion = 'rechazar'
       AND v_estado_actual = 'pendiente' THEN

        v_estado_nuevo := 'rechazado';

    ELSIF p_accion = 'revocar'
       AND v_estado_actual = 'aprobado' THEN

        v_estado_nuevo := 'revocado';

    ELSE
        RAISE EXCEPTION
            'Transicion de estado no permitida';
    END IF;

    UPDATE public.organizers
    SET estado = v_estado_nuevo,
        verificado = (v_estado_nuevo = 'aprobado')
    WHERE id = p_organizer_id;

    INSERT INTO public.organizer_audit_log (
        admin_user_id,
        organizer_id,
        accion,
        motivo
    )
    VALUES (
        v_admin_id,
        p_organizer_id,
        p_accion,
        p_motivo
    );

END;
$$;

REVOKE ALL ON FUNCTION public.admin_decidir_organizador(
    uuid, text, text
)
FROM PUBLIC, anon, authenticated, service_role;

GRANT EXECUTE ON FUNCTION public.admin_decidir_organizador(
    uuid, text, text
)
TO authenticated;

-- ------------------------------------------------------------
-- FIN DE ADMIN-01 V2
-- ------------------------------------------------------------

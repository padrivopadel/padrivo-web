-- ADMIN-01: Prueba negativa de autorizacion
-- Ejecutar dentro de una transaccion controlada.

SET LOCAL ROLE authenticated;

SELECT set_config(
    'request.jwt.claim.sub',
    '11111111-1111-4111-8111-111111111111',
    true
);

SELECT public.admin_decidir_organizador(
    '22222222-2222-4222-8222-222222222222',
    'aprobar',
    'Prueba de autorizacion'
);
# SEC-01 — Decisión aprobada: organizadores verificados

Fecha: 2026-11-18. Estado: **regla funcional confirmada; pruebas locales de RLS realizadas; flujo administrativo aún no implementado**.

## Reglas aprobadas

1. Solo un organizador registrado y verificado puede crear o modificar sus torneos.
2. Un usuario autenticado puede solicitar el alta de su propio organizador, inicialmente `verificado=false`. No puede solicitar en nombre de otro usuario, duplicar su solicitud ni verificarse.
3. **Solo administradores autorizados de PADRIVO PÁDEL** podrán aprobar, rechazar o revocar la verificación. El administrador debe autenticarse; la autorización debe comprobarse en el backend/base de datos, no únicamente en el frontend.
4. La revocación debe bloquear inmediatamente nuevas escrituras de torneos por parte del organizador.
5. Registrar, aprobar, rechazar y revocar son acciones distintas. Se debe auditar actor, momento, objetivo y motivo para decisiones administrativas.

## Requisitos de implementación

- Nunca confiar en `raw_user_meta_data` para roles ni permitir que el usuario escriba `profiles.rol`.
- No exponer `service_role` ni claves secretas al navegador.
- Comprobar que la identidad administrativa se determina con una fuente protegida y verificable. No basta con `rol` en el JWT si no está protegido o actualizado.
- Proteger `organizers.verificado`, `organizers.user_id` y la propiedad de `tournaments.organizer_id` con permisos de columna, RLS y backend.
- Definir un estado de rechazo y reintento sin permitir que un usuario restablezca su verificación.
- Revisar compatibilidad con torneos históricos: producción tiene dos torneos y cero organizadores; no reasignarlos ni borrarlos automáticamente.

## Evidencia de pruebas locales reportadas por usuario

- Usuario ficticio pudo crear solicitud propia con `verificado=false` y no pudo crearla para otro usuario.
- Índice único impidió duplicar la solicitud.
- Intento de actualizar `verificado` como `authenticated` devolvió `permission denied`.
- RLS rechazó creación de torneo sin verificación y permitió crear torneo con verificación.
- RLS permitió editar torneo propio mientras estaba verificado y devolvió `UPDATE 0` tras revocación.
- Las pruebas se hicieron en Supabase local con transacciones y `ROLLBACK` cuando correspondía. **No equivalen a pruebas completas mediante Auth/API ni autorizan despliegue a producción.**

## Pendientes antes de producción

1. Inspeccionar código de autenticación y administración actual para diseñar autorización administrativa segura.
2. Implementar flujo de aprobación/rechazo/revocación y auditoría; probar roles administrativos reales y negativos.
3. Resolver el contrato de `tournaments.organizer_id` y la migración de los dos torneos existentes.
4. Probar el flujo completo con Supabase Auth/API en ambiente aislado, revisión de rollback y asesores de seguridad.
5. Revisar la migración final y solicitar autorización expresa antes de tocar producción.

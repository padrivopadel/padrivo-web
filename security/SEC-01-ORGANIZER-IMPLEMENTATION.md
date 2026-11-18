# SEC-01 — Alta de organizadores (candidato local)

**Estado:** preparado en GitHub; NO ejecutado ni validado. No modificar producción.

## Evidencia remota, solo lectura (2026-11-18)

- `organizers`: `id uuid DEFAULT gen_random_uuid()` es PK; `user_id uuid` nullable; `verificado boolean DEFAULT false` nullable; `nombre`, `telefono`, `descripcion` opcionales.
- Solo existe política `organizers_read` SELECT (true) en el estado remoto; SEC-01 la convierte en owner-only.
- 0 organizadores, 2 torneos; ambos sin correspondencia en `organizers.id` ni `organizers.user_id`. Se requiere decidir cómo migrar/reasignar esos torneos antes del despliegue.
- No hay FK que garantice el significado de `tournaments.organizer_id`.

## Archivo candidato

`security/sql/SEC-01-organizer-request-candidate.sql` se aplica **después** de `SEC-01-migration.sql`, solo en una base local descartable y mediante `psql -X -v ON_ERROR_STOP=1 -1`. No es migración de producción.

- Crea índice único para impedir más de una solicitud por `user_id`.
- Otorga INSERT únicamente a `user_id, nombre, telefono, descripcion`.
- RLS INSERT exige `user_id=auth.uid()` y `verificado=false`.
- Sin permisos de UPDATE para usuario final; la aprobación administrativa requiere backend seguro separado.
- La solicitud NO cambia `profiles.rol`.

## Pruebas de integración pendientes

1. Verificar que `SEC-01-migration.sql` funciona en base original aislada (no solo en base ya corregida).
2. Usuario A crea solicitud propia; queda `verificado=false`; A puede leer su solicitud.
3. Usuario A no puede crear segunda solicitud; B no puede solicitar en nombre de A.
4. A no puede enviar `verificado=true`, ni modificar `verificado`, `user_id` o datos de B.
5. Sin verificación, A no puede crear torneo. Un operador confiable verifica A (solo en entorno local); entonces A puede crear y editar su torneo; B no.
6. Revocar verificación y comprobar que A ya no puede modificar su torneo.
7. Confirmar qué significa `organizer_id`, preservar los dos torneos existentes y revisar si una lectura pública de organizadores es necesaria.
8. Revisar SQLSTATE de denegaciones y pruebas positivas, no aceptar fallos por constraints como prueba suficiente de RLS.
9. Ensayar reversión sin restaurar privilegios vulnerables.

## Pendiente de producto

Definir la interfaz de solicitud, proceso de aprobación (identidad de operador, auditoría, rechazo y reintento) y directorio público sin teléfono/email. No se debe exponer `service_role` en frontend.

## Nota de ejecución

El script usa `SET LOCAL`: ejecutar dentro de una transacción real mediante `psql -1`; no usar el editor SQL remoto. Confirmar primero con `git status` y los archivos locales que la versión de SEC-01 aplicada coincide con GitHub.

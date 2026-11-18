# SEC-01 — Decisión aprobada: organizadores verificados

Fecha: 2026-11-18. Estado: **decisión funcional confirmada; implementación pendiente de pruebas de integración**.

## Regla aprobada por el propietario

Solo un organizador **registrado y verificado** puede crear o modificar torneos en PADRIVO PÁDEL. Registrarse no otorga verificación; el usuario no puede verificarse a sí mismo. Revocar la verificación debe bloquear nuevas escrituras del organizador.

## Contrato de autorización propuesto

1. **Solicitud de organizador:** usuario autenticado solicita alta vinculada a su `auth.uid()`. Estado inicial `verificado=false`. Nunca se acepta `verificado`, `user_id` arbitrario o `rol` del cuerpo de una petición para elevar privilegios.
2. **Aprobación/revocación:** exclusivamente operador confiable desde backend o procedimiento administrativo autenticado fuera del cliente público. No exponer `service_role` ni claves secretas en frontend. Auditar quién, cuándo y por qué aprueba o revoca.
3. **Torneos:** las políticas RLS de INSERT y UPDATE exigen existencia de organizador vinculado al usuario y `verificado IS TRUE`. Deben comprobar propiedad y evitar transferir `organizer_id`.
4. **Rol de cuenta:** todas las altas nuevas empiezan con `profiles.rol='jugador'`, incluso si solicitan `raw_user_meta_data.rol='administrador'`. El rol no es una fuente de autorización confiable si el cliente puede escribirlo.
5. **Registros existentes:** no alterar automáticamente roles o torneos previos. Revisar asignaciones con operador confiable y preservar datos.

## Bloqueos concretos detectados en producción (solo consultas de lectura)

- RLS habilitado en las cuatro tablas; nueve políticas existentes.
- `anon` aún puede ejecutar `public.handle_new_user()`; `authenticated` aún puede modificar `profiles.rol` y `player_profiles.puntos_ranking`.
- Hay **0 registros en organizers**, **2 torneos** y **1 perfil con rol distinto de jugador**. Ninguno de los dos torneos coincide hoy con `organizers.id` o `organizers.user_id`; **no inferir el significado de organizer_id** sin revisar el contrato de la aplicación.
- Aplicar ahora el candidato bloquearía la creación/modificación de torneos hasta disponer de un flujo de aprobación y de organizadores verificados.

## Secuencia para completar SEC-01

1. Confirmar mediante esquema y código que `tournaments.organizer_id` referencia el identificador del usuario (no el PK de `organizers`). Ajustar el modelo si es necesario, con migración compatible para torneos existentes.
2. Diseñar el alta segura de organizador: solicitud limitada al propio usuario, campos permitidos, `verificado=false` impuesto por servidor/default y protección de columnas.
3. Diseñar aprobación/revocación administrativa con control de identidad y registro de auditoría. No permitir actualizaciones directas a `verificado` desde `authenticated`.
4. Probar en Supabase local aislado con usuarios ficticios: solicitante, no verificado, verificado, revocado y usuario ajeno. Incluir altas reales por Auth, RLS, grants de columnas, torneo existente y rollback.
5. Revisar compatibilidad de perfiles privados y directorio público, y aprobar contrato separado para datos visibles.
6. Preparar migración versionada, respaldo de esquema/ACL, revisión de diferencias y plan de reversión segura. Aplicar a producción solo después de superar estas verificaciones y aprobar el despliegue.

## Límites de esta aprobación

La confirmación autoriza la **regla de negocio**, no implica que la migración esté validada ni autoriza por sí sola cambios directos de producción. Los scripts `security/sql/SEC-01-migration.sql` y `security/sql/SEC-01-candidate.sql` siguen sujetos a pruebas y revisión. No se crearon servicios con costo ni se ejecutó DDL de producción en esta etapa.

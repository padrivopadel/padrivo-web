# PADRIVO PADEL — ADMIN-01 V2
## Registro de validacion local

**Fecha:** 2026-11-18
**Rama:** `security/sec-01`
**Estado:** Validacion local superada para los escenarios documentados.
**Produccion:** No desplegado.

## 1. Objetivo

Validar el mecanismo administrativo de autorizacion de organizadores,
sus transiciones de estado, la conservacion del historial y las
restricciones de acceso a torneos mediante PostgreSQL y Supabase RLS.

## 2. Migracion principal

Archivo: `security/sql/ADMIN-01-migration-v2.sql`

La migracion incorpora:

- Tabla protegida `public.admin_users`.
- Estados pendiente, aprobado, rechazado y revocado.
- Consistencia entre estado y verificado.
- Indice unico parcial para solicitudes activas.
- Historial de solicitudes mediante nuevas filas.
- Tabla `public.organizer_audit_log`.
- Funcion administrativa `public.admin_decidir_organizador`.
- Restricciones de privilegios y autorizacion.

La migracion requiere reconciliacion previa si existen
organizadores en la base de datos de destino.

## 3. Grupos de pruebas

Cada grupo se ejecuta en una transaccion independiente,
con `BEGIN` y `ROLLBACK` externos.

### Grupo A — Aprobacion, transiciones e historial

Orden:

1. `ADMIN-01-migration-v2.sql`
2. `ADMIN-01-test-approved.sql`
3. `ADMIN-01-test-invalid-transitions.sql`
4. `ADMIN-01-test-reapply.sql`
5. `ADMIN-01-test-duplicate.sql`

Escenarios validados:

- Aprobacion administrativa.
- Registro de auditoria.
- Rechazo de transiciones invalidas.
- Revocacion.
- Nueva solicitud despues de revocacion.
- Conservacion del historial.
- Bloqueo de solicitudes activas duplicadas.

### Grupo B — Rechazo y nueva solicitud

Orden:

1. `ADMIN-01-migration-v2.sql`
2. `ADMIN-01-test-rejected-reapply.sql`

Escenarios validados:

- Rechazo administrativo.
- Registro de auditoria.
- Nueva solicitud despues de rechazo.
- Conservacion del historial.

### Grupo C — RLS de torneos

Orden:

1. `ADMIN-01-migration-v2.sql`
2. `ADMIN-01-test-tournaments-rls.sql`
3. `ADMIN-01-test-tournaments-update.sql`

Escenarios validados:

- Organizador pendiente no puede crear torneos.
- Organizador aprobado puede crear torneos.
- Organizador aprobado puede actualizar su torneo.
- Organizador aprobado no puede actualizar torneos ajenos.
- Modificacion de `organizer_id` bloqueada.
- Organizador revocado no puede crear torneos.
- Organizador revocado no puede actualizar su torneo.

Verificaciones adicionales mediante `ROW_COUNT`:

- Actualizacion propia: exactamente 1 fila.
- Actualizacion ajena: exactamente 0 filas.
- Actualizacion tras revocacion: exactamente 0 filas.

### Grupo D — Autorizacion administrativa negativa

Orden:

1. `ADMIN-01-migration-v2.sql`
2. `ADMIN-01-test-unauthorized.sql`

Resultado esperado:

La funcion administrativa rechaza al usuario no autorizado
con el mensaje `Operacion no autorizada`.

Esta prueba espera un error SQL y debe evaluarse verificando
el mensaje y el codigo de salida correspondiente.

## 4. Privilegios y protecciones

Se inspeccionaron los permisos de `public.organizers`,
`public.admin_users`, `public.organizer_audit_log`
y `public.tournaments`.

En torneos, el rol `authenticated` utiliza privilegios
por columna para INSERT y UPDATE.

No se requieren permisos generales de INSERT o UPDATE
sobre toda la tabla para los escenarios probados.

Los campos protegidos, incluidos `organizer_id`
durante UPDATE y los contadores de inscripciones,
no tienen permisos de actualizacion para authenticated.

## 5. Seguridad de las pruebas

- Entorno: PostgreSQL local en Docker.
- Contenedor: `supabase_db_padrivo-web`.
- Cliente: `psql -X -v ON_ERROR_STOP=1`.
- Transacciones externas con `BEGIN` y `ROLLBACK`.
- Sin modificaciones confirmadas en produccion.
- Sin despliegues ni commits durante la validacion.

Se comprobo posteriormente la ausencia de:

- `public.admin_users`.
- `public.organizer_audit_log`.
- `public.admin_decidir_organizador`.
- Columna `public.organizers.estado`.
- Indice parcial `organizers_user_id_active_unique`.

La inspeccion local finalizo con codigo de salida 0.

## 6. Archivos historicos

Los siguientes archivos son borradores anteriores:

- `ADMIN-01-migration.sql`
- `ADMIN-01-test-local.sql`

No forman parte de la bateria de validacion V2.
Se conservan temporalmente sin eliminarlos.

## 7. Limitaciones y pendientes

Antes de considerar un despliegue:

1. Verificar el esquema y los datos reales del entorno destino.
2. Resolver la reconciliacion si existen organizadores.
3. Revisar dependencias de la aplicacion con el nuevo flujo.
4. Preparar un procedimiento de despliegue y recuperacion.
5. Revisar el alcance completo de seguridad de SEC-01.
6. Aprobar explicitamente cualquier operacion en produccion.

Las pruebas locales no equivalen a una auditoria integral
ni autorizan por si solas un despliegue.

## 8. Conclusion

ADMIN-01 V2 supero las pruebas locales documentadas
de estados, autorizacion administrativa, historial,
privilegios y RLS de torneos.

La etapa queda como candidata para revision y preparacion
de integracion, sin despliegue en produccion.
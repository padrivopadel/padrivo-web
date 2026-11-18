# SEC-01 — Hallazgos verificados y propuesta de corrección

Fecha: 2026-11-18. Rama GitHub: `security/sec-01`. Inspección de solo lectura de Supabase `padrivo-v1` (proyecto `ajsejzkhrfbglwiihdpi`). No se consultaron filas con datos personales ni se ejecutó DDL/DML.

## Hallazgo 1 — Rol elegido desde metadata del usuario (crítico)

Definición actual de `public.handle_new_user()` (`SECURITY DEFINER`, trigger de alta):

```sql
coalesce(new.raw_user_meta_data->>'rol','jugador')
```

El resultado se inserta en `public.profiles.rol`. `raw_user_meta_data` es controlable por el usuario; no puede fundamentar autorización. Corregir a rol inicial fijo `'jugador'` (o flujo de asignación administrado), y verificar si roles preexistentes necesitan revisión. No cambiar roles existentes automáticamente.

## Hallazgo 2 — Funciones privilegiadas expuestas

`public.handle_new_user()` y `public.set_profile_email()` son `SECURITY DEFINER`. La consulta `has_function_privilege` devuelve `true` para `anon` y `authenticated` en ambas. El asesor de Supabase marca ejecución pública. Propuesta: revocar `EXECUTE` a `PUBLIC`, `anon` y `authenticated` (y comprobar grants heredados), preservando ejecución por triggers. Evaluar la dependencia de triggers antes de aplicar. La función `set_profile_email()` no tiene `search_path` fijado; referenciar `auth.users` explícitamente y fijar `search_path` seguro. `handle_new_user()` fija `search_path=public`; revisar uso de nombres calificados.

## Hallazgo 3 — Privilegios de columnas y políticas

`profiles_select`, `player_profiles_select` y `organizers_read` tienen `USING (true)` para usuarios autenticados. `profiles` y `organizers` contienen información de contacto. `profiles_update` permite actualizar filas propias; `player_profiles_update` permite actualizar estadísticas de filas propias. Los grants de columnas inspeccionados indican permisos amplios; se necesita comprobar privilegios efectivos de tabla y columnas, y definir lecturas públicas compatibles con la aplicación.

`tournaments` permite insertar si `auth.uid() = organizer_id`, sin verificación adicional de organizador. Aclarar si `organizer_id` es el ID del usuario o de la fila `organizers`, y si se exige `verificado=true` para crear/publicar.

**Nota:** ausencia de `WITH CHECK` explícito en UPDATE no significa ausencia automática de validación del nuevo estado.

## Hallazgo 4 — Configuración de autenticación

Asesor de seguridad: `auth_leaked_password_protection` desactivado. Habilitar tras revisar disponibilidad/configuración del plan, sin alterar otros parámetros de autenticación.

## Estado de entorno de pruebas

`list_branches` devuelve ninguna rama de desarrollo Supabase; `list_migrations` devuelve ninguna migración registrada. Por tanto no hay rama aislada existente en la que ejecutar y verificar una corrección. Crear una rama de Supabase puede generar cargos; confirmar precio antes de hacerlo. **No aplicar a producción sin pruebas de alta, aislamiento, permisos y reversión.**

## Secuencia propuesta

1. Crear ambiente aislado compatible con el esquema y triggers; comprobar coste de Supabase Branching y/o opción local.
2. Preparar migración que corrija rol inicial, permisos EXECUTE y `search_path`; guardar definiciones originales para reversión.
3. Ejecutar pruebas: registro con metadata `rol=admin` termina en rol jugador; registro normal sigue funcionando; llamadas RPC no autorizadas no pueden ejecutar funciones privilegiadas.
4. Preparar controles de columna y RLS para perfiles, estadísticas, organizadores y torneos; probar dos usuarios, anónimo y administrador.
5. Revisar alertas de npm por separado, sin `audit fix` automático.
6. Aplicar en producción únicamente después de validación satisfactoria y plan de rollback.

## Fuentes técnicas

- https://supabase.com/docs/guides/database/postgres/column-level-security
- https://supabase.com/docs/guides/database/database-linter?lint=0011_function_search_path_mutable
- https://supabase.com/docs/guides/database/database-linter?lint=0028_anon_security_definer_function_executable
- https://supabase.com/docs/guides/database/database-linter?lint=0029_authenticated_security_definer_function_executable
- https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

Estado: documento de diagnóstico. Ninguna corrección aplicada en Supabase.

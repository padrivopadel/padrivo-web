# SEC-01 — Plan de endurecimiento de permisos (borrador para revisión)

Estado: DIAGNÓSTICO DOCUMENTADO. **No aplicado a Supabase.** Rama: `security/sec-01`, derivada de UI-01 `6c8c8cc`.

## Evidencia de solo lectura — 2026-11-18

Se consultaron `information_schema.columns` y `pg_policies` de `profiles`, `player_profiles`, `organizers` y `tournaments`, sin consultar registros de personas ni ejecutar cambios.

- `profiles`: `profiles_select` permite SELECT a `authenticated` con `USING (true)`. La tabla contiene `email`, `telefono` y `rol`. `profiles_update` usa `auth.uid() = id`; hay que impedir que el usuario modifique `rol`.
- `player_profiles`: SELECT `USING (true)`; UPDATE `auth.uid() = user_id`. Columnas competitivas: `partidos`, `victorias`, `derrotas`, `puntos_ranking`. Evitar edición por el propio jugador.
- `organizers`: SELECT `USING (true)`; contiene `telefono`, `verificado` y `user_id`.
- `tournaments`: INSERT `WITH CHECK (auth.uid() = organizer_id)`; UPDATE `USING (auth.uid() = organizer_id)`. Falta comprobación explícita de elegibilidad/organizador verificado, según modelo de negocio por aprobar.
- Trigger detectado: `trg_set_profile_email` en INSERT de `profiles`. Revisar definición, privilegios y `search_path` de la función antes de modificarla.

**Precisión PostgreSQL:** `UPDATE` sin `WITH CHECK` explícito no implica automáticamente que no exista control sobre el nuevo estado: PostgreSQL puede reutilizar `USING`. El problema prioritario aquí es qué *columnas* puede modificar cada rol.

## Decisiones propuestas (a aprobar)

1. **Datos privados:** decidir si el directorio público necesita nombre, ciudad y foto. Separar los campos privados (email/teléfono) de la superficie pública, mediante tabla/vista `security_invoker` cuidadosamente validada o permisos de columnas. Evitar romper lecturas existentes con `SELECT *`.
2. **Roles:** no confiar en `user_metadata` para autorización. Rol asignado por proceso privilegiado y verificado en servidor/BD. Limitar privilegios de UPDATE sobre `profiles.rol`; revisar trigger de alta.
3. **Estadísticas:** permitir a jugadores editar solo campos de perfil expresamente aprobados, nunca `partidos`, `victorias`, `derrotas` o `puntos_ranking`. La actualización de estadísticas debe proceder de una operación de resultados autorizada.
4. **Organizadores y torneos:** definir si `verificado=true` es obligatorio para publicar/crear torneos; exigir correspondencia real entre `organizers.user_id` y el usuario autenticado. Verificar relación `organizer_id` y esquema antes de proponer SQL.
5. **Permisos efectivos:** consultar grants de tabla y columna para `anon`/`authenticated`, además de funciones, triggers, claves foráneas y políticas dependientes. No asumir que RLS sola protege columnas.
6. **Dependencias npm:** evaluar separadamente las 11 alertas históricas; no ejecutar `npm audit fix` sin analizar impacto y estado actual.

## Pruebas necesarias antes de cualquier migración

- Usuario A no puede leer email/teléfono de B, ni cambiar su propio rol.
- Usuario A puede editar solo campos de perfil permitidos y no puede alterar estadísticas.
- Usuario no organizador no puede crear ni modificar torneos.
- Organizador elegible solo puede modificar torneos propios.
- Accesos legítimos al directorio, ranking y perfiles siguen funcionando.
- Probar con dos usuarios y rol anónimo en entorno aislado, con verificaciones de grants y RLS.

## Riesgos y reversión

No aplicar revocaciones masivas ni reemplazar políticas en producción sin inventario de consumidores, snapshot de definiciones y plan de reversión probado. Evitar funciones SECURITY DEFINER en esquemas expuestos. No almacenar claves secretas en GitHub.

## Límites de esta etapa

Solo documentación en GitHub. **Sin migraciones, DDL, cambios de datos, secretos, merges a main ni despliegues.** Próximo paso: inspección de grants efectivos, función de perfiles, relaciones y modelo de permisos, y preparación de SQL de propuesta en una etapa posterior.

## Continuación SEC-01 — 2026-11-18
Preparación de SQL autorizada en esta sesión, sin permiso de producción. Ver [paquete y resultados](SEC-01-IMPLEMENTATION.md). Borrador, pruebas y reversión guardados; ejecución pendiente de entorno aislado. Metadatos puntuales confirman ausencia de FK en las cuatro tablas, grants amplios de tabla y rol inicial desde metadata. Decisiones sobre identificador de organizador, verificación y superficie pública pendientes. No se consultaron datos personales ni se aplicaron correcciones.

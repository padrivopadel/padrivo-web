# SEC-01 — Revisión independiente del paquete de Work (2026-11-18)

**Alcance:** revisión estática de los archivos del commit `d7ea4cb4eaec001e8472815060c9fd3907bb05c8`. No se ejecutó SQL, no se creó infraestructura ni se modificó Supabase. **No apto para producción todavía.**

## Veredicto

La propuesta aborda correctamente el origen inseguro de `profiles.rol`, los `SECURITY DEFINER`, la protección de columnas de estadísticas y la necesidad de verificar organizadores. Sin embargo, la revisión estática no demuestra que las reglas sean correctas ni que las pruebas vayan a pasar en un entorno equivalente.

## Bloqueos antes de ejecutar / fusionar

1. **Entorno aislado con esquema completo.** El archivo de evidencia es un inventario parcial, no un respaldo reproducible. Los triggers sobre `auth.users` y `profiles` requieren una instalación Supabase compatible. No sustituirla por tablas simuladas sin explicitar la limitación.
2. **Candidato termina en `ROLLBACK`.** Está bien como precaución. Para probarlo de verdad en entorno aislado, usar una copia controlada que termine en `COMMIT`; nunca indicar que el archivo actual modificó la BD.
3. **Test de signup real.** La inserción directa a `auth.users` no equivale al alta a través del servicio Auth; además debe comprobarse contra los `NOT NULL`, índices, triggers y defaults de una instalación concreta. Separar prueba SQL de trigger y prueba de registro por API.
4. **Cobertura de casos negativos.** Además del resultado de `insufficient_privilege`, asegurar que se distingan denegaciones por RLS, ausencia de filas y errores por constraints. Un fallo de constraints no demuestra seguridad. Comprobar `sqlstate` cuando corresponda y confirmar que una operación legítima equivalente sí funciona.
5. **Permisos de negocio.** `organizers` no tendrá INSERT/UPDATE para el cliente. Hay que definir cómo se solicita el alta y quién cambia `verificado`. `profiles` pasará a lectura solo propia: directorio de jugadores y perfiles públicos requerirán un contrato separado de datos no sensibles.
6. **Semántica de `organizer_id`.** La política usa UUID de `auth.users`, no `organizers.id`; las cuatro tablas no tienen FK. Confirmar los consumidores y consistencia antes de imponerlo. No incorporar un FK sin revisar datos reales.
7. **Estadísticas y ranking.** El usuario no puede modificar columnas competitivas; debe existir flujo servidor confiable para resultados, categoría y nivel. Confirmar si `categoria` y `nivel` son autoeditables.
8. **Reversión.** `SEC-01-rollback.sql` restaura permisos y código previamente inseguros. Conservarlo únicamente para ensayo aislado; plan de producción debe privilegiar rollback transaccional o corrección hacia adelante. Capturar ACL y políticas completas inmediatamente antes de una implementación.
9. **Pruebas de integración y efectos laterales.** Simular anon, jugador A, jugador B, organizador no verificado, verificado, revocación de verificación y servicio de backend sin exponer `service_role`. Verificar funciones y grants efectivos después de aplicar cambios.
10. **No confundir CI frontend con pruebas RLS.** Un build correcto no valida SQL ni seguridad Supabase.

## Decisiones funcionales recomendadas

- Rol inicial de toda cuenta nueva: **`jugador`**. Escalamiento de privilegios únicamente por operador confiable.
- Torneos: **solo organizador verificado** puede crear o modificar; cualquier cambio de estado debe bloquear nuevas modificaciones. Definir quién valida a los organizadores.
- Perfiles privados: **solo propietario**; para perfiles visibles de terceros, un directorio específico sin email ni teléfono.
- Estadísticas oficiales: **no autoeditables**; cargar resultados desde backend autorizado. Definir aparte si nivel/categoría inicial son declarativos o validados.

Estas recomendaciones no constituyen aprobación automática para producción.

## Siguiente acción

Preparar entorno local aislado con Docker/CLI o evaluar Supabase Branching con aprobación del costo, restaurar esquema completo, ejecutar el candidato y pruebas mejoradas con usuarios ficticios, ensayar reversión y documentar resultados. Solo después proponer PR de revisión; no merge ni despliegue automático.

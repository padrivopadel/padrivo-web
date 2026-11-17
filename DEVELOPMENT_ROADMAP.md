# Roadmap
| ID | Prioridad / complejidad | Dependencia | Archivos/area | Riesgo | Aceptacion/pruebas | Estado |
|---|---|---|---|---|---|---|
| BASE-01 | P0 / baja | Commit oficial | globals.css y documentos | Cambio visual | npm ci, lint, build, revision portada | En validacion; ver TESTING_STATUS |
| SEC-01 | P0 / alta | Auditoria existente | SQL propuesto y pruebas aisladas | Privilegios/registro | Aislamiento usuarios, rol y estadisticas protegidos | Pendiente aprobacion; no ejecutar migraciones |
| NAV-01 | P1 / media | BASE-01 | Navbar, rutas, componentes | Enlaces rotos | Navegacion movil/teclado y destinos reales | Propuesta |
| AUTH-01 | P0 / alta | BASE-01 y SEC-01 | lib/supabase, proxy, auth, perfiles | Sesiones/datos | Registro, recuperacion y permisos con dos usuarios | Propuesta |
| CLUB-01 | P1 / alta | AUTH-01 y diseno aprobado | Canchas/paneles | Edicion cruzada | Alta, moderacion, lectura publica aprobada | Propuesta |
| SPORT-01 | P1 / alta | AUTH-01 | Torneos e inscripciones | Cupos/duplicados | Inscripciones y resultados consistentes | Propuesta |
| TEACH-01 | P2 / media | AUTH-01 | Profesores | Permisos | Directorio y edicion propia | Propuesta |
| SHOP-01 | P2 / alta | AUTH-01 | Catalogo/pedidos | Stock/pagos | Compras de prueba e idempotencia | Propuesta |
| RANK-01 | P2 / alta | SPORT-01 y reglamento | Ranking | Puntuacion | Casos aprobados y recalculo | Propuesta |
| PROD-01 | P2 / alta | Validaciones y permiso | Vercel/SEO | Publicacion | Build, seguridad, responsive | Propuesta |
Vercel fue consultado con acceso autorizado: cero proyectos y despliegues disponibles en padrivopadel. No prueba ausencia historica de proyectos eliminados. No repetir auditorias sin cambios relevantes.

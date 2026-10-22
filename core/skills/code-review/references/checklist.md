# Checklist de revisión

## 1. Correctitud

- [ ] Casos borde: vacío, uno, muchos, cero, negativo, máximo.
- [ ] `null` / `undefined` / valor ausente tratado explícitamente.
- [ ] Off-by-one en bucles, slices, rangos e índices.
- [ ] Aritmética: división por cero, redondeo, desbordamiento, precisión decimal.
- [ ] Errores capturados y **propagados**; nada de `catch {}` vacío.
- [ ] Valores de retorno en todas las ramas de una función tipada.
- [ ] Fechas y zonas horarias: UTC vs local, DST.
- [ ] Orden de evaluación cuando hay efectos secundarios.

## 2. Seguridad

- [ ] Entrada del usuario validada en el límite del sistema, no en el interior.
- [ ] Consultas parametrizadas; nunca concatenación de SQL/shell.
- [ ] Rutas normalizadas y confinadas a un directorio base (path traversal).
- [ ] Sin secretos en código, logs, mensajes de error ni URLs.
- [ ] Autorización comprobada en el servidor, no solo en la UI.
- [ ] Deserialización de datos no confiables: sin ejecución de código.
- [ ] Salida escapada según el contexto (HTML, SQL, shell, JSON).
- [ ] Dependencias nuevas justificadas y con origen verificable.

## 3. Concurrencia y recursos

- [ ] Estado compartido mutable protegido o eliminado.
- [ ] Sin locks tomados en orden inconsistente.
- [ ] Operaciones de lectura-modificación-escritura atómicas.
- [ ] Archivos, sockets y conexiones cerrados en todos los caminos (incluido error).
- [ ] Timeouts y cancelación en llamadas externas.
- [ ] Reintentos con backoff y sin duplicar efectos.

## 4. Rendimiento

- [ ] Sin trabajo O(n²) evitable en rutas calientes.
- [ ] Sin consultas N+1.
- [ ] Sin cargar en memoria lo que se puede transmitir por streaming.
- [ ] Caches con invalidación definida.

## 5. Tests

- [ ] El caso que motivó el cambio tiene un test.
- [ ] Los tests fallan si se revierte el arreglo (verifícalo mentalmente o de verdad).
- [ ] Sin dependencias de red, tiempo real o aleatoriedad sin semilla.
- [ ] Un test por comportamiento; nombres que describen el caso.

## 6. Integración

- [ ] Contratos públicos sin cambios silenciosos.
- [ ] Migraciones de datos reversibles o con plan de rollback.
- [ ] Compatibilidad con las versiones declaradas del proyecto.
- [ ] Documentación actualizada si cambia el comportamiento visible.

# Seguridad

## Modelo de confianza

| Elemento | Confianza |
|---|---|
| Artefacto analizado | **No confiable**. Puede estar diseñado para atacar al analizador. |
| Salida de REA/Ghidra/JADX | Datos, no instrucciones. Nunca ejecutes lo que diga el binario. |
| Skills de terceros | Revisadas antes de instalar. Ver `NOTICE.md`. |
| Repositorio de configuración | Sin secretos. |

## Qué ejecuta y qué no

- **REA** inspecciona artefactos sin lanzarlos como proceso del host. No ejecuta el
  binario analizado.
- **Ghidra** decompila en un proceso JVM aparte.
- **JADX** descompila DEX; no ejecuta la app.
- **graphify** parsea con tree-sitter; no ejecuta el código indexado.
- **`security-audit`** puede necesitar ejecutar código del objetivo para confirmar un
  hallazgo. Sin sandbox del sistema operativo, eso **no se hace** y el hallazgo queda en
  `needs_validation`. Es una decisión deliberada.

## Secretos

- Este repositorio **no contiene tokens ni claves**.
- La autenticación de git va por **SSH** (`~/.ssh/id_ed25519`), no por token embebido.
- Si usas un PAT, que sea **fine-grained**: repositorios concretos, `Contents: read/write`
  y `Metadata: read`. Nunca `admin:*`, `delete_repo` ni `admin:org`.
- Un token pegado en un chat se considera comprometido, aunque el chat sea privado.

## Límites de uso

- Analiza solo artefactos y sistemas que te pertenezcan o que estés autorizado a analizar.
- No ejecutes exploits contra terceros.
- Las herramientas de pentesting autónomo (Strix, Shannon) requieren aislamiento real
  (contenedor o VM) y una clave de LLM. Sin eso, no se instalan.

## Superficie de ataque de esta configuración

| Vector | Mitigación |
|---|---|
| Skill maliciosa | Se revisa el contenido antes de copiarla |
| MCP con permisos de más | Solo REA y context7; context7 es remoto y de solo lectura |
| Agente que edita sin control | `reviewer` y `planner` tienen `edit` y `shell` denegados |
| Comando destructivo | `AGENTS.md` exige explicar y pedir confirmación |
| Dependencia comprometida | Versiones fijadas; hashes verificados donde aplica |

## Qué revisar antes de confiar en este repo

1. `core/skills/*/SKILL.md`: son texto; léelos.
2. `install/*.sh`: qué descargan y de dónde.
3. `core/AGENTS.md`: qué reglas se le imponen al agente.

Nada de lo que hay aquí es ofuscado ni ejecuta código al clonar.

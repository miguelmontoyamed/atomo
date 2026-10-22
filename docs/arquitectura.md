# Arquitectura

## Capas

```
Capa 4  Átomo (agente primario)
        └── decide, delega, responde

Capa 3  Instrucciones
        └── AGENTS.md: tabla de ruteo + reglas duras

Capa 2  Capacidades
        ├── MCP: REA (207 tools), context7
        ├── Skills: security-audit, code-review, git-release, sofia, graphify
        └── Herramientas nativas del harness: shell, edit, read, browser

Capa 1  Motores
        ├── Ghidra (nativo)
        ├── JADX (Android)
        └── tree-sitter (graphify)
```

## Por qué `AGENTS.md` es el centro

El modelo no consulta un registro de herramientas. En cada turno recibe:

- Nombres y descripciones de las tools.
- `description` de las skills (solo eso).
- `description` de los agentes.
- `AGENTS.md` completo.

`AGENTS.md` es el único sitio donde puedes escribir una regla que se aplique **siempre**.
Por eso la tabla de ruteo vive ahí y no en un comentario de código.

## Por qué rutas absolutas

OpenCode (y casi cualquier harness) lanza los MCP como procesos hijos. Ese proceso no
hereda el PATH de tu shell interactivo: hereda el del proceso que lo lanzó. En una app de
escritorio, ese PATH suele ser el del sistema (`/usr/local/bin:/usr/bin:...`), sin
`~/.local/bin`.

Consecuencia práctica:

```json
"command": ["node", "rea.mjs", "mcp"]          // funciona en terminal, falla en la app
"command": ["/home/tu/.local/bin/node", "..."] // funciona en ambos
```

El mismo razonamiento aplica al `shell` del agente y a las variables `JAVA_HOME`,
`GHIDRA_INSTALL_DIR` y `REA_JADX_MCP_JAR`.

## Flujo de una petición

1. El usuario pide algo.
2. Átomo clasifica: código, artefacto, seguridad, docs, web, texto.
3. Busca la categoría en la tabla de `AGENTS.md`.
4. Si duda del estado de una capacidad, ejecuta `oc-capabilities`.
5. Ejecuta, observa y responde separando observado / inferido / desconocido.

## Modos de fallo (y su síntoma)

| Fallo | Síntoma | Causa real |
|---|---|---|
| MCP no arranca | `mcp list` sin `rea` | Ruta relativa o `node` fuera de PATH |
| Motor sin variables | `GHIDRA_INSTALL_DIR is not set` | `environment` no aplicado al proceso hijo |
| Agente sin git | `command not found: git` | `shell` no apunta al wrapper |
| Skill invisible | El agente no la usa nunca | `description` no coincide con la petición |
| Elección errática | Usa grep en vez de REA | Falta una fila en la tabla o la descripción es ambigua |

## Qué es determinista y qué no

**Determinista:** `oc-capabilities` (comprueba binarios, procesos, archivos),
`graphify` (tree-sitter), `git`, los MCP una vez conectados.

**No determinista:** la elección de herramienta por parte del modelo. Se reduce con la
tabla y con descripciones precisas, pero no se elimina. Cualquier guía que prometa lo
contrario está mintiendo.

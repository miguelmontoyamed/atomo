# Cursor

Estado: **no verificado en esta máquina**. Formatos documentados por Cursor.

## Instrucciones

Cursor lee `AGENTS.md` en la raíz del proyecto y reglas en `.cursor/rules/`.

Opción A — por proyecto (recomendada):

```bash
cp core/AGENTS.md ./
```

Opción B — regla global:

```bash
mkdir -p ~/.cursor/rules
{
  echo '---'
  echo 'description: Átomo — reglas globales'
  echo 'alwaysApply: true'
  echo '---'
  echo
  cat core/AGENTS.md
} > ~/.cursor/rules/atomo.mdc
```

## MCP

Edita `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "rea": {
      "command": "/home/TU_USUARIO/.local/opt/node-v24.22.1-linux-x64/bin/node",
      "args": [
        "/home/TU_USUARIO/.local/lib/node_modules/rea-agents/scripts/rea.mjs",
        "mcp"
      ],
      "env": {
        "JAVA_HOME": "/home/TU_USUARIO/.local/opt/jdk21",
        "GHIDRA_INSTALL_DIR": "/home/TU_USUARIO/.local/opt/ghidra_12.1.4_PUBLIC"
      }
    },
    "context7": {
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

Reinicia Cursor. En **Settings → MCP** deben aparecer en verde.

## Skills

Cursor no usa `SKILL.md` de forma nativa. Dos salidas:

1. Convierte cada skill en una regla `.mdc` (mismo contenido, otro envoltorio).
2. Mantén las skills en `~/.agents/skills/` y referencia su ruta desde `AGENTS.md` para
   que el agente las lea cuando haga falta.

La opción 2 conserva el formato estándar y evita duplicar contenido.

## Diferencias

- Sin subagentes con permisos propios (`reviewer`, `verifier`).
- Sin comandos `/review`, `/commit`.
- El modelo no ve las skills hasta que las lee: el `description` debe estar en
  `AGENTS.md` para que sepa que existen.

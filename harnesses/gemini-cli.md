# Gemini CLI

Estado: **no verificado en esta máquina**. Formatos documentados por Gemini CLI.

## Instrucciones

Gemini CLI lee `GEMINI.md`:

```bash
cp core/AGENTS.md ~/.gemini/GEMINI.md
```

Por proyecto, en la raíz: `GEMINI.md`.

## MCP

Edita `~/.gemini/settings.json`:

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
      "httpUrl": "https://mcp.context7.com/mcp"
    }
  }
}
```

> Algunas versiones usan `url` en vez de `httpUrl` para servidores remotos. Si `context7`
> no conecta, prueba la otra clave.

## Skills

Gemini CLI tiene sistema de extensiones. No es idéntico a `SKILL.md`; la vía portable es
mantener las skills en `~/.agents/skills/` y citarlas desde `GEMINI.md`:

```markdown
## Skills disponibles
- `~/.agents/skills/security-audit/SKILL.md` — auditoría de seguridad
- `~/.agents/skills/code-review/SKILL.md` — revisión de código
- `~/.agents/skills/git-release/SKILL.md` — commits y releases
```

## Verificación

```bash
gemini mcp list
```

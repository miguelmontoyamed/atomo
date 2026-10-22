# Claude Code

Estado: **no verificado en esta máquina**. Formatos documentados por Claude Code.

## Instrucciones

Claude Code lee `CLAUDE.md`, no `AGENTS.md`. Copia y renombra:

```bash
cp core/AGENTS.md ~/.claude/CLAUDE.md
```

O, por proyecto, en la raíz del repo.

## Skills

Ruta nativa:

```bash
mkdir -p ~/.claude/skills
cp -r core/skills/* ~/.claude/skills/
```

Cada skill debe conservar su `SKILL.md` con frontmatter `name` y `description`.
Ese `description` es lo único que Claude ve antes de decidir cargarla: no lo recortes.

## MCP

```bash
claude mcp add --transport stdio rea \
  --env JAVA_HOME="$HOME/.local/opt/jdk21" \
  --env GHIDRA_INSTALL_DIR="$HOME/.local/opt/ghidra_12.1.4_PUBLIC" \
  -- node "$HOME/.local/lib/node_modules/rea-agents/scripts/rea.mjs" mcp

claude mcp add --transport http context7 https://mcp.context7.com/mcp
```

Comprueba con `claude mcp list`.

## Agentes

Claude Code usa subagentes en `~/.claude/agents/*.md`, con frontmatter `name`,
`description` y `tools`. No es el mismo esquema que OpenCode
(`mode: subagent`, `permissions:`), así que los archivos de `agents/` **no** se copian
tal cual: hay que traducir el frontmatter.

Ejemplo mínimo:

```markdown
---
name: reviewer
description: Revisa cambios buscando bugs, regresiones y problemas de seguridad. Solo lectura.
tools: Read, Grep, Glob
---
Revisa el diff. No edites archivos.
```

## Verificación

Dentro de Claude Code:

```
/mcp
```

Debe listar `rea` y `context7` como conectados.

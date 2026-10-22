# Codex (OpenAI)

Estado: **no verificado en esta máquina**. Los formatos siguientes son los documentados
por Codex CLI; confirma con `codex --help` en tu versión.

## Instrucciones

Codex lee `AGENTS.md`. Coloca el núcleo en:

```bash
mkdir -p ~/.codex
cp core/AGENTS.md ~/.codex/AGENTS.md
```

Para un proyecto concreto, copia `AGENTS.md` a la raíz del repo.

## Skills

Codex soporta skills en formato `SKILL.md`. Copia el directorio:

```bash
mkdir -p ~/.codex/skills
cp -r core/skills/* ~/.codex/skills/
```

Si tu versión no las detecta, el contenido sigue siendo útil: son instrucciones en texto
que puedes referenciar desde `AGENTS.md`.

## MCP

Edita `~/.codex/config.toml`:

```toml
[mcp_servers.rea]
command = "/home/TU_USUARIO/.local/opt/node-v24.22.1-linux-x64/bin/node"
args = [
  "/home/TU_USUARIO/.local/lib/node_modules/rea-agents/scripts/rea.mjs",
  "mcp"
]
env = { JAVA_HOME = "/home/TU_USUARIO/.local/opt/jdk21", GHIDRA_INSTALL_DIR = "/home/TU_USUARIO/.local/opt/ghidra_12.1.4_PUBLIC" }

[mcp_servers.context7]
url = "https://mcp.context7.com/mcp"
```

Codex necesita rutas absolutas igual que OpenCode, por el mismo motivo: el proceso hijo
no hereda tu PATH interactivo.

## Diferencias con la guía de OpenCode

- No existen los agentes `reviewer` / `verifier` / `planner` como subagentes con permisos
  propios. En Codex, pide la tarea directamente y usa el modo de solo lectura si tu versión
  lo ofrece.
- `/review`, `/commit` y `/explain` son comandos de OpenCode. En Codex, describe la tarea
  y el `AGENTS.md` hará que se comporte igual.
- El plugin `@heretek-ai/opencode-rea` es exclusivo de OpenCode. En Codex, REA funciona
  solo como MCP.

## Verificación

```bash
node /ruta/rea.mjs doctor --provider ghidra
node /ruta/rea.mjs doctor --provider jadx
```

Si ambos responden `healthy`, el MCP servirá.

# Hermes y otros harnesses

Estado: **genérico**. Hermes no se ha probado en esta máquina; esta guía cubre cualquier
agente que cumpla dos condiciones: **soporta MCP** y **lee instrucciones de un archivo**.

## Receta universal

Tres piezas, en este orden:

### 1. Instrucciones

Copia `core/AGENTS.md` al archivo que tu harness lea como instrucciones de sistema
(`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `system prompt`, etc.).

Si no tiene un archivo de instrucciones, pégalo como prompt de sistema. Es lo que hace
que el agente sepa qué existe y cuándo usarlo.

### 2. MCP

Registra los dos servidores de `core/mcp.json`.

**REA (stdio):**

```
comando: <NODE_ABS>/node
args:    ["<REA_ROOT>/scripts/rea.mjs", "mcp"]
env:     JAVA_HOME=<JDK21>
         GHIDRA_INSTALL_DIR=<GHIDRA>
         REA_JADX_MCP_JAR=<JADX_JAR>
```

**context7 (HTTP):**

```
url: https://mcp.context7.com/mcp
```

Las rutas deben ser **absolutas**. Casi todos los harnesses lanzan los MCP como procesos
hijos sin heredar tu PATH interactivo; es el fallo número uno al portar esta configuración.

### 3. Skills

Copia `core/skills/` a la carpeta de skills de tu harness. Si no tiene una, deja las
skills en `~/.agents/skills/` y añade a las instrucciones:

```markdown
## Skills disponibles
Lee `~/.agents/skills/<nombre>/SKILL.md` cuando la tarea coincida con su descripción.
```

El formato `SKILL.md` con frontmatter `name` + `description` es el estándar de facto.
El `description` es lo que el agente ve antes de decidir; escríbelo pensando en cuándo
debe activarse, no en qué contiene.

## Particularidades de Hermes

Si Hermes es un agente sobre OpenCode o similar, revisa primero si ya lee
`~/.config/opencode/` o `~/.agents/`. En ese caso no dupliques: apunta a esas rutas.

Si es un harness propio, lo importante es que el modelo reciba:

1. La tabla de capacidades (texto).
2. Los servidores MCP (procesos).
3. Las skills (archivos que pueda leer).

Con esas tres piezas, el comportamiento es el mismo que en OpenCode.

## Qué NO es portable

- Los agentes con permisos (`reviewer`, `verifier`, `planner`): cada harness tiene su
  esquema. Traduce el frontmatter.
- Los comandos `/review`, `/commit`, `/explain`: son de OpenCode. En otros, pide la tarea.
- El plugin `@heretek-ai/opencode-rea`: exclusivo de OpenCode. REA sigue disponible
  como MCP.

## Verificación

```bash
node <REA_ROOT>/scripts/rea.mjs doctor --provider ghidra
node <REA_ROOT>/scripts/rea.mjs doctor --provider jadx
node <REA_ROOT>/scripts/rea.mjs doctor --provider none
```

Los tres deben responder sin error antes de culpar al harness.

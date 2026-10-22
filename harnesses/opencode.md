# OpenCode

Estado: **verificado** en OpenCode 2.1.2 (Linux Mint 22.3).

## Qué usa OpenCode

| Pieza | Dónde vive |
|---|---|
| Instrucciones globales | `~/.config/opencode/AGENTS.md` |
| Configuración y MCP | `~/.config/opencode/opencode.json` |
| Agentes | `~/.config/opencode/agents/*.md` |
| Comandos | `~/.config/opencode/commands/*.md` |
| Skills | `~/.config/opencode/skills/<nombre>/SKILL.md` |
| Plugins npm | clave `plugins` de `opencode.json` |

## Instalación

```bash
./install/opencode.sh
```

El script detecta las rutas reales de Node, REA, JDK, Ghidra y JADX, hace copia de
seguridad de tu configuración y genera un `opencode.json` válido.

## Configuración resultante

```json
{
  "default_agent": "atomo",
  "shell": "/home/TU_USUARIO/.local/bin/oc-shell",
  "mcp": {
    "rea": {
      "type": "local",
      "command": ["/ruta/abs/node", "/ruta/abs/rea.mjs", "mcp"],
      "enabled": true,
      "environment": {
        "JAVA_HOME": "/ruta/jdk21",
        "GHIDRA_INSTALL_DIR": "/ruta/ghidra",
        "REA_JADX_MCP_JAR": "/ruta/jadx.jar"
      }
    },
    "servers": {
      "context7": { "type": "remote", "url": "https://mcp.context7.com/mcp", "enabled": true }
    }
  },
  "plugins": ["@heretek-ai/opencode-rea"]
}
```

### Tres detalles que cuestan horas si no se saben

1. **Rutas absolutas obligatorias.** La app de escritorio lanza los MCP con un PATH que
   no incluye `~/.local/bin`. Si pones `"command": ["node", ...]` funciona en la terminal
   y falla en la app.
2. **`shell` con ruta absoluta.** El `PATH` del agente no hereda tu `.profile`. El wrapper
   `oc-shell` inyecta `~/.local/bin` y las variables de Java/Ghidra/JADX.
3. **No uses `rea setup --client opencode` a ciegas**: puede reescribir `command` y volver
   a dejarlo relativo. Comprueba después.

## Verificación

```bash
oc-capabilities --full
```

Salida esperada:

```
rea       connected
context7  connected
ghidra    OK
jadx      OK
```

## Comandos

| Comando | Qué hace |
|---|---|
| `/capacidades` | Estado real de todo lo instalado |
| `/review` | Revisa el diff con el agente `reviewer` (solo lectura) |
| `/commit` | Prepara el commit con `git-release` |
| `/explain` | Explica un archivo o subsistema |
| `/rea` | Delega en el agente de análisis profundo |

## Solución de problemas

- **`rea` no aparece en `mcp list`**: revisa la ruta absoluta de `node` y que `rea.mjs`
  exista. Ejecuta el comando a mano para ver el error real.
- **`ghidra FALLO: GHIDRA_INSTALL_DIR is not set`**: el `environment` del MCP no llegó al
  proceso. Verifica que `JAVA_HOME` apunte a un JDK 21 con `jdk.compiler`.
- **El agente no ve `git`**: `oc-shell` no está aplicado. Comprueba `echo $PATH` desde el
  agente.

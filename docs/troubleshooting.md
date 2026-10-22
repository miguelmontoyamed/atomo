# Solución de problemas

Todos los fallos de esta página se observaron realmente durante la instalación.

## `rea` no aparece en `mcp list`

**Síntoma:** `opencode-cli mcp list` no lista `rea`, o lo lista y falla al conectar.

**Causa:** el comando usa una ruta relativa o `node` no está en el PATH del proceso.

**Comprobación:**

```bash
python3 -c "import json;print(json.load(open('$HOME/.config/opencode/opencode.json'))['mcp']['rea']['command'])"
```

**Solución:** ambos elementos deben ser absolutos:

```json
"command": ["/home/tu/.local/opt/node-v24.22.1-linux-x64/bin/node",
            "/home/tu/.local/lib/node_modules/rea-agents/scripts/rea.mjs", "mcp"]
```

Ejecuta esa misma línea a mano en una terminal para ver el error real.

---

## `ghidra FALLO: GHIDRA_INSTALL_DIR is not set`

**Síntoma:** `oc-capabilities --full` funciona dentro del MCP pero falla en la shell.

**Causa:** las variables están en el bloque `environment` del MCP, que solo aplica a ese
proceso. La shell del agente es otro proceso distinto.

**Solución:** exportarlas también en el wrapper de shell:

```sh
JAVA_HOME="$HOME/.local/opt/jdk21"
GHIDRA_INSTALL_DIR="$HOME/.local/opt/ghidra_12.1.4_PUBLIC"
REA_JADX_MCP_JAR="$HOME/.local/share/rea/android/jadx-headless-mcp-0.7.1-all.jar"
export JAVA_HOME GHIDRA_INSTALL_DIR REA_JADX_MCP_JAR
```

Y apuntar `"shell"` a ese script con ruta absoluta.

---

## `jadx FALLO: Set REA_JADX_MCP_JAR...`

**Causa:** el JAR no existe o la ruta es relativa.

**Comprobación:**

```bash
ls -l ~/.local/share/rea/android/jadx-headless-mcp-0.7.1-all.jar
sha256sum ~/.local/share/rea/android/jadx-headless-mcp-0.7.1-all.jar
```

El hash publicado para 0.7.1 empieza por `6e5eacf5`. Si no coincide, el archivo está
corrupto o es otro build.

---

## El agente no encuentra `git`

**Síntoma:** `git: command not found` dentro del agente, pero funciona en tu terminal.

**Causa:** el agente no hereda tu `~/.profile`.

**Solución:** `"shell": "/home/tu/.local/bin/oc-shell"`, donde `oc-shell` antepone
`~/.local/bin` al PATH antes de ejecutar bash.

---

## `python3 -m venv` falla: `ensurepip is not available`

**Causa:** falta el paquete `python3-venv` (requiere sudo).

**Solución sin sudo:** usa `uv`.

```bash
curl -fsSL -o /tmp/uv.tar.gz https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-unknown-linux-gnu.tar.gz
tar -xzf /tmp/uv.tar.gz -C /tmp
cp /tmp/uv-x86_64-unknown-linux-gnu/uv ~/.local/bin/uv && chmod +x ~/.local/bin/uv
uv venv ~/.local/opt/graphify-venv --python 3.12
uv pip install --python ~/.local/opt/graphify-venv/bin/python graphifyy
```

---

## `Duplicate plugin ID` al iniciar

**Causa:** dos copias del plugin de graphify (una en el proyecto y otra en el global) se
cargan a la vez.

**Solución:** deja solo una. Si quieres el comportamiento global, elimina
`.opencode/plugins/graphify.js` del proyecto.

---

## La skill existe pero el agente no la usa

**Causa:** el modelo solo ve el `description` del frontmatter antes de decidir.

**Solución:** reescribe el `description` en términos de **cuándo** activarla, no de qué
contiene. Ejemplo:

```yaml
# malo
description: Auditoría de seguridad

# bueno
description: Audita seguridad de repos, APIs y servicios. Úsala cuando pidan revisar
  vulnerabilidades, auditar, pentest o evaluar riesgos de un código.
```

---

## El flujo de dispositivo de GitHub no autoriza

**Síntoma:** el código caduca o la página no responde.

**Alternativas, en orden:**

1. Ejecuta `gh auth login` en **tu** terminal (interactivo, funciona siempre).
2. Usa SSH para git: `ssh-keygen -t ed25519`, registra la pública y listo.
3. Token fine-grained, solo si necesitas la API.

Nunca pegues un token con `admin:*` en un chat.

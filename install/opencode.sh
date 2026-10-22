#!/usr/bin/env bash
# Átomo — instala la configuración de OpenCode con rutas absolutas de esta máquina.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$HERE")"
CONF="${HOME}/.config/opencode"
BIN="${HOME}/.local/bin"

say()  { printf '\n\033[1;36m── %s ──\033[0m\n' "$1"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
die()  { printf '  \033[31m✗\033[0m %s\n' "$1" >&2; exit 1; }

say "Detección de rutas"

NODE_BIN="$(command -v node || true)"
[ -n "$NODE_BIN" ] || die "node no está en PATH."
ok "node: $NODE_BIN"

REA_MJS=""
for c in \
  "${HOME}/.local/lib/node_modules/rea-agents/scripts/rea.mjs" \
  "$(npm root -g 2>/dev/null || true)/rea-agents/scripts/rea.mjs"; do
  [ -f "$c" ] && REA_MJS="$c" && break
done
[ -n "$REA_MJS" ] || die "No encuentro rea.mjs. Instala con: npm install -g rea-agents"
ok "rea:  $REA_MJS"

JAVA_HOME_DETECTED=""
for c in "${HOME}/.local/opt/jdk21" "${HOME}/.local/opt/jdk-21"*; do
  [ -x "${c}/bin/java" ] && JAVA_HOME_DETECTED="$c" && break
done
[ -n "$JAVA_HOME_DETECTED" ] && ok "jdk:   $JAVA_HOME_DETECTED" || warn "JDK 21 no encontrado (Ghidra no funcionará)."

GHIDRA_DIR=""
for c in "${HOME}/.local/opt/ghidra_"*"_PUBLIC" /opt/ghidra_*_PUBLIC; do
  [ -d "$c" ] && GHIDRA_DIR="$c" && break
done
[ -n "$GHIDRA_DIR" ] && ok "ghidra: $GHIDRA_DIR" || warn "Ghidra no encontrado."

JADX_JAR=""
for c in "${HOME}/.local/share/rea/android/jadx-headless-mcp-"*"-all.jar"; do
  [ -f "$c" ] && JADX_JAR="$c" && break
done
[ -n "$JADX_JAR" ] && ok "jadx:  $JADX_JAR" || warn "JADX no encontrado (Android no funcionará)."

say "Copia de seguridad"
mkdir -p "$CONF"
if [ -f "${CONF}/opencode.json" ]; then
  cp "${CONF}/opencode.json" "${CONF}/opencode.json.bak.$(date +%Y%m%d-%H%M%S)"
  ok "configuración anterior respaldada"
fi

say "Shell del agente"
cat > "${BIN}/oc-shell" <<'EOF'
#!/bin/sh
PATH="$HOME/.local/bin:$PATH"
JAVA_HOME="${JAVA_HOME:-$HOME/.local/opt/jdk21}"
GHIDRA_INSTALL_DIR="${GHIDRA_INSTALL_DIR:-$HOME/.local/opt/ghidra_12.1.4_PUBLIC}"
REA_JADX_MCP_JAR="${REA_JADX_MCP_JAR:-$HOME/.local/share/rea/android/jadx-headless-mcp-0.7.1-all.jar}"
export PATH JAVA_HOME GHIDRA_INSTALL_DIR REA_JADX_MCP_JAR
exec /bin/bash "$@"
EOF
chmod +x "${BIN}/oc-shell"
ok "~/.local/bin/oc-shell"

say "Generación de opencode.json"
NODE_BIN="$NODE_BIN" REA_MJS="$REA_MJS" JAVA_HOME_DETECTED="$JAVA_HOME_DETECTED" \
GHIDRA_DIR="$GHIDRA_DIR" JADX_JAR="$JADX_JAR" CONF="$CONF" BIN="$BIN" \
python3 <<'PY'
import json, os
from pathlib import Path

conf = Path(os.environ["CONF"])
path = conf / "opencode.json"
cfg = {}
if path.exists():
    try:
        cfg = json.loads(path.read_text())
    except json.JSONDecodeError:
        cfg = {}

cfg["default_agent"] = "atomo"
cfg["shell"] = str(Path(os.environ["BIN"]) / "oc-shell")

mcp = cfg.setdefault("mcp", {})
rea = {
    "type": "local",
    "command": [os.environ["NODE_BIN"], os.environ["REA_MJS"], "mcp"],
    "enabled": True,
}
env = {}
if os.environ["JAVA_HOME_DETECTED"]:
    env["JAVA_HOME"] = os.environ["JAVA_HOME_DETECTED"]
if os.environ["GHIDRA_DIR"]:
    env["GHIDRA_INSTALL_DIR"] = os.environ["GHIDRA_DIR"]
if os.environ["JADX_JAR"]:
    env["REA_JADX_MCP_JAR"] = os.environ["JADX_JAR"]
if env:
    rea["environment"] = env
mcp["rea"] = rea

servers = mcp.setdefault("servers", {})
servers["context7"] = {
    "type": "remote",
    "url": "https://mcp.context7.com/mcp",
    "enabled": True,
}

plugins = cfg.setdefault("plugins", [])
if "@heretek-ai/opencode-rea" not in plugins:
    plugins.append("@heretek-ai/opencode-rea")

path.write_text(json.dumps(cfg, indent=2, ensure_ascii=False) + "\n")
print("  ✓", path)
PY

say "Agentes, comandos y skills"
mkdir -p "${CONF}/agents" "${CONF}/commands" "${CONF}/skills"
cp "$ROOT"/agents/*.md "${CONF}/agents/"
cp "$ROOT"/commands/*.md "${CONF}/commands/"
cp -r "$ROOT"/core/skills/* "${CONF}/skills/"
ok "copiados a $CONF"

say "Verificador"
cp "$ROOT/verify/oc-capabilities" "${BIN}/oc-capabilities"
chmod +x "${BIN}/oc-capabilities"
ok "~/.local/bin/oc-capabilities"

say "Comprobación"
"${BIN}/oc-capabilities" | sed -n '/Servidores MCP/,/Skills/p' || true

printf '\n  Reinicia OpenCode y selecciona el agente \033[1mátomo\033[0m.\n'
printf '  Luego: oc-capabilities --full\n\n'

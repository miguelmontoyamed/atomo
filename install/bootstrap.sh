#!/usr/bin/env bash
# Átomo — instalador de dependencias.
# Uso: ./install/bootstrap.sh [opciones]
#   --with-ghidra    descarga Ghidra 12.1.4 + JDK 21 (~1 GB)
#   --with-jadx      descarga jadx-headless-mcp 0.7.1 (~50 MB)
#   --with-graphify  instala graphify en un venv aislado (~160 MB)
#   --with-gh        instala GitHub CLI en ~/.local
#   --with-opencode  copia la configuración de OpenCode
#   --all            equivale a todas las anteriores
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$HERE")"
PREFIX="${HOME}/.local"
BIN="${PREFIX}/bin"
OPT="${PREFIX}/opt"
TMP="${PREFIX}/tmp"

GHIDRA_VERSION="12.1.4"
JADX_VERSION="0.7.1"
JADX_JAR="${PREFIX}/share/rea/android/jadx-headless-mcp-${JADX_VERSION}-all.jar"

WANT_GHIDRA=0 WANT_JADX=0 WANT_GRAPHIFY=0 WANT_GH=0 WANT_OPENCODE=0

for arg in "$@"; do
  case "$arg" in
    --with-ghidra)   WANT_GHIDRA=1 ;;
    --with-jadx)     WANT_JADX=1 ;;
    --with-graphify) WANT_GRAPHIFY=1 ;;
    --with-gh)       WANT_GH=1 ;;
    --with-opencode) WANT_OPENCODE=1 ;;
    --all)           WANT_GHIDRA=1 WANT_JADX=1 WANT_GRAPHIFY=1 WANT_GH=1 WANT_OPENCODE=1 ;;
    -h|--help)       sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "Opción desconocida: $arg" >&2; exit 1 ;;
  esac
done

say()  { printf '\n\033[1;36m── %s ──\033[0m\n' "$1"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
die()  { printf '  \033[31m✗\033[0m %s\n' "$1" >&2; exit 1; }

mkdir -p "$BIN" "$OPT" "$TMP"

say "Sistema"
[ "$(uname -s)" = "Linux" ] || die "Este instalador asume Linux."
ok "$(uname -s) $(uname -m)"
command -v curl >/dev/null || die "Falta curl."
command -v python3 >/dev/null || die "Falta python3."
ok "curl y python3 presentes"

say "Node.js"
if command -v node >/dev/null; then
  NODE_V="$(node -v)"
  NODE_MAJOR="${NODE_V#v}"; NODE_MAJOR="${NODE_MAJOR%%.*}"
  [ "$NODE_MAJOR" -ge 20 ] || die "Node $NODE_V es demasiado antiguo (se requiere ≥ 20)."
  ok "node $NODE_V"
else
  warn "Node no encontrado."
  cat <<'EOF'
  Instálalo sin sudo (ejemplo):
    mkdir -p ~/.local/opt && cd ~/.local/opt
    curl -fsSLO https://nodejs.org/dist/v24.22.1/node-v24.22.1-linux-x64.tar.xz
    tar -xf node-v24.22.1-linux-x64.tar.xz
    ln -sf ~/.local/opt/node-v24.22.1-linux-x64/bin/node ~/.local/bin/node
    ln -sf ~/.local/opt/node-v24.22.1-linux-x64/bin/npm  ~/.local/bin/npm
  Luego vuelve a ejecutar este script.
EOF
  exit 1
fi

say "REA"
if command -v rea >/dev/null; then
  ok "rea $(rea --version 2>/dev/null || echo presente)"
else
  npm config set prefix "$PREFIX"
  npm install -g rea-agents
  ok "rea-agents instalado en $BIN"
fi

say "Skills portables"
mkdir -p "${HOME}/.agents/skills"
cp -r "$ROOT"/core/skills/* "${HOME}/.agents/skills/"
ok "skills en ~/.agents/skills"

if [ "$WANT_GH" = 1 ]; then
  say "GitHub CLI"
  if command -v gh >/dev/null; then
    ok "gh $(gh --version | head -1)"
  else
    TAG="$(curl -sL https://api.github.com/repos/cli/cli/releases/latest | python3 -c 'import json,sys;print(json.load(sys.stdin)["tag_name"])')"
    VER="${TAG#v}"
    curl -fsSL -o "$TMP/gh.tar.gz" "https://github.com/cli/cli/releases/download/${TAG}/gh_${VER}_linux_amd64.tar.gz"
    tar -xzf "$TMP/gh.tar.gz" -C "$TMP"
    rm -rf "$OPT/gh" && mv "$TMP/gh_${VER}_linux_amd64" "$OPT/gh"
    ln -sf "$OPT/gh/bin/gh" "$BIN/gh"
    rm -f "$TMP/gh.tar.gz"
    ok "gh ${VER}"
  fi
fi

if [ "$WANT_GHIDRA" = 1 ]; then
  say "JDK 21"
  if [ -x "${OPT}/jdk21/bin/java" ]; then
    ok "JDK ya presente"
  else
    ARCH="x64"
    [ "$(uname -m)" = "aarch64" ] && ARCH="aarch64"
    URL="https://api.adoptium.net/v3/binary/latest/21/ga/linux/${ARCH}/jdk/hotspot/normal/eclipse?project=jdk"
    curl -fsSL -o "$TMP/jdk.tar.gz" "$URL"
    mkdir -p "$TMP/jdk" && tar -xzf "$TMP/jdk.tar.gz" -C "$TMP/jdk"
    JDK_DIR="$(find "$TMP/jdk" -maxdepth 1 -type d -name 'jdk-*' | head -1)"
    rm -rf "$OPT/jdk21" && mv "$JDK_DIR" "$OPT/jdk21"
    rm -rf "$TMP/jdk" "$TMP/jdk.tar.gz"
    ok "JDK 21 en $OPT/jdk21"
  fi

  say "Ghidra ${GHIDRA_VERSION}"
  if [ -d "${OPT}/ghidra_${GHIDRA_VERSION}_PUBLIC" ]; then
    ok "Ghidra ya presente"
  else
    GH_URL="$(curl -sL https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest \
      | python3 -c 'import json,sys;print(next(a["browser_download_url"] for a in json.load(sys.stdin)["assets"] if a["name"].endswith(".zip")))')"
    curl -fSL -o "$TMP/ghidra.zip" "$GH_URL"
    command -v unzip >/dev/null || die "Falta unzip."
    unzip -q "$TMP/ghidra.zip" -d "$OPT"
    rm -f "$TMP/ghidra.zip"
    ok "Ghidra en $OPT/ghidra_${GHIDRA_VERSION}_PUBLIC"
  fi
fi

if [ "$WANT_JADX" = 1 ]; then
  say "JADX ${JADX_VERSION}"
  if [ -f "$JADX_JAR" ]; then
    ok "JAR ya presente"
  else
    mkdir -p "$(dirname "$JADX_JAR")"
    JADX_URL="https://github.com/skylot/jadx/releases/download/v${JADX_VERSION}/jadx-${JADX_VERSION}.zip"
    curl -fsSL -o "$TMP/jadx.zip" "$JADX_URL"
    command -v unzip >/dev/null || die "Falta unzip."
    unzip -q "$TMP/jadx.zip" -d "$TMP/jadx"
    warn "Este paquete es la CLI de JADX. REA necesita el bridge 'jadx-headless-mcp'."
    warn "Descárgalo según la documentación de REA y colócalo en: $JADX_JAR"
    rm -rf "$TMP/jadx" "$TMP/jadx.zip"
  fi
fi

if [ "$WANT_GRAPHIFY" = 1 ]; then
  say "graphify"
  if command -v graphify >/dev/null; then
    ok "graphify $(graphify --version 2>/dev/null | head -1)"
  else
    if ! command -v uv >/dev/null; then
      curl -fsSL -o "$TMP/uv.tar.gz" https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-unknown-linux-gnu.tar.gz
      tar -xzf "$TMP/uv.tar.gz" -C "$TMP"
      cp "$TMP/uv-x86_64-unknown-linux-gnu/uv" "$BIN/uv"
      chmod +x "$BIN/uv"
      rm -rf "$TMP/uv.tar.gz" "$TMP/uv-x86_64-unknown-linux-gnu"
    fi
    uv venv "$OPT/graphify-venv" --python 3.12
    uv pip install --python "$OPT/graphify-venv/bin/python" -q graphifyy
    ln -sf "$OPT/graphify-venv/bin/graphify" "$BIN/graphify"
    ok "graphify $(graphify --version 2>/dev/null | head -1)"
  fi
fi

if [ "$WANT_OPENCODE" = 1 ]; then
  say "OpenCode"
  "$HERE/opencode.sh"
fi

say "Siguiente paso"
cat <<EOF
  Verifica el estado real:
    oc-capabilities --full

  Si oc-capabilities no está en PATH:
    cp "$ROOT/verify/oc-capabilities" "$BIN/" && chmod +x "$BIN/oc-capabilities"
EOF

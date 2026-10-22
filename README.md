# Átomo

Configuración reproducible de un agente de código que **sabe qué tiene instalado y lo usa**.
Núcleo portable para OpenCode, Codex, Claude Code, Cursor, Gemini CLI y Hermes.

> Átomo no es un modelo. Es el conjunto de instrucciones, skills y servidores MCP que
> convierten a un agente cualquiera en uno que elige la herramienta correcta en vez de
> la más cómoda.

---

## El problema que resuelve

Un agente no "sabe" qué tienes instalado. En cada turno ve cuatro cosas:

1. Las herramientas cargadas y su descripción.
2. El `description` de cada skill (no su contenido).
3. La descripción de cada agente.
4. El archivo `AGENTS.md`, que se inyecta siempre.

Con eso decide, por coincidencia semántica. Si nada le dice que existe un decompilador,
no lo usará; y si algo falla, dirá "no puedo" sin comprobarlo.

Átomo ataca las tres causas:

| Causa | Solución en este repo |
|---|---|
| No sabe qué existe | Tabla de ruteo explícita en `AGENTS.md` |
| No sabe si funciona | `oc-capabilities`, que comprueba de verdad |
| Elige mal | Descripciones precisas de skills y agentes |

---

## Arquitectura

```
                         ┌─────────────────┐
                         │      Átomo      │
                         │  (agente raíz)  │
                         └────────┬────────┘
                                  │ lee
                    ┌─────────────┴─────────────┐
                    │        AGENTS.md          │
                    │  tabla de capacidades     │
                    └─────────────┬─────────────┘
                                  │ enruta a
     ┌────────────┬───────────────┼───────────────┬────────────┐
     │            │               │               │            │
┌────▼────┐  ┌────▼─────┐   ┌─────▼──────┐  ┌─────▼─────┐ ┌────▼────┐
│   REA   │  │ context7 │   │   Skills   │  │  Agentes  │ │ Browser │
│  (MCP)  │  │  (MCP)   │   │ SKILL.md   │  │ subagentes│ │  tools  │
└────┬────┘  └──────────┘   └────────────┘  └───────────┘ └─────────┘
     │
  ┌──┴──────────┬──────────────┐
  │             │              │
┌─▼─────┐  ┌────▼────┐   ┌─────▼──────┐
│Ghidra │  │  JADX   │   │  nativo:   │
│nativo │  │ Android │   │ .NET, WASM │
└───────┘  └─────────┘   └────────────┘

Opcional, por proyecto:
┌──────────────────────────────────────────┐
│ graphify → graphify-out/graph.json       │
│ consultas estructurales sin gastar LLM   │
└──────────────────────────────────────────┘
```

---

## Qué incluye

| Componente | Qué aporta | Licencia |
|---|---|---|
| **REA** (207 herramientas MCP) | Binarios, Electron/JS, .NET, APK, firmware, WASM, SQLite, red | ver `NOTICE.md` |
| **Ghidra 12.1.4** | Decompilación nativa | Apache-2.0 |
| **JADX 0.7.1** | Decompilación Android | Apache-2.0 |
| **context7** (MCP) | Documentación actualizada de librerías | servicio externo |
| **security-audit** | Auditoría de seguridad en 6 fases | MIT (Cloudflare) |
| **code-review** | Revisión con checklist | propia |
| **git-release** | Commits y releases limpios | propia |
| **sofia** | Reescritura de prompts | MIT (Opsafy) |
| **graphify** (opcional) | Grafo de conocimiento del proyecto | Apache-2.0 |
| **Átomo + reviewer/verifier/planner** | Agentes con permisos acotados | propia |

---

## Requisitos

**Mínimos:**
- Linux x86_64 (probado en Linux Mint 22.3)
- Node.js ≥ 20
- Git
- 4 GB de RAM para el flujo básico

**Para análisis nativo:**
- JDK 21
- Ghidra 12.x (~900 MB en disco)
- 6 GB de RAM recomendados

**Para Android:**
- JADX `jadx-headless-mcp` 0.7.1 (JAR)

> En una máquina de 3,7 GB todo funciona, pero **no lances más de dos subagentes a la vez**.
> Los agentes son procesos independientes.

---

## Instalación

### OpenCode (completa)

```bash
git clone https://github.com/miguelmontoyamed/atomo.git
cd atomo
./install/bootstrap.sh --with-opencode
```

El instalador:

1. Comprueba Node, Git y Python.
2. Instala `rea-agents` en `~/.local`.
3. Descarga JDK 21, Ghidra y JADX **solo si pasas `--with-ghidra` / `--with-jadx`**.
4. Copia agentes, comandos y skills a `~/.config/opencode/`.
5. Genera `opencode.json` con **rutas absolutas de tu máquina** (imprescindible: la app
   de escritorio lanza los MCP con un PATH que no incluye `~/.local/bin`).
6. Instala `oc-capabilities` y `oc-shell`.

Después, verifica:

```bash
oc-capabilities --full
```

Debe mostrar `ghidra OK` y `jadx OK`. Si no, revisa `docs/troubleshooting.md`.

### Otros harnesses

El núcleo es portable. Elige tu guía:

- [Codex](harnesses/codex.md)
- [Claude Code](harnesses/claude-code.md)
- [Cursor](harnesses/cursor.md)
- [Gemini CLI](harnesses/gemini-cli.md)
- [Hermes](harnesses/hermes.md)

En todos: `core/AGENTS.md` + `core/skills/` + los servidores MCP de `core/mcp.json`.

---

## Uso

Una vez instalado, el agente primario es **Átomo**. Se activa como agente por defecto y
decide según la tabla de `AGENTS.md`.

| Pides… | Usa… |
|---|---|
| "¿Qué hace este binario?" | REA `inspect_binary_layout` |
| "Decompila esta función" | REA + Ghidra `analyze_function` |
| "Analiza este APK" | REA + JADX |
| "Audita la seguridad de este repo" | skill `security-audit` |
| "Revisa mi diff" | agente `reviewer` |
| "Crea el commit" | skill `git-release` |
| "Comprueba que pasa los tests" | agente `verifier` |
| "Planifica esto sin tocar código" | agente `planner` |
| "¿Cómo se usa esta librería?" | MCP `context7` |
| "Entiende este repo grande" | skill `graphify` (si hay `graphify-out/`) |

---

## Cómo decide (sin magia)

No hay un conmutador. El agente lee `AGENTS.md` y elige. Esto **sesga** la elección,
no la garantiza.

Lo que sí es determinista es `oc-capabilities`: comprueba binarios, MCP, skills, agentes,
comandos y motores. Cuando el agente duda, ejecuta eso en vez de suponer.

Si ves que elige mal, la corrección es editar una descripción o añadir una fila a la tabla.
No hace falta instalar nada más.

---

## Seguridad

Lee [`docs/seguridad.md`](docs/seguridad.md). Resumen:

- Los MCP se lanzan con rutas absolutas y variables propias.
- No hay tokens en este repositorio.
- `security-audit` **no confirma** un hallazgo que requiera ejecutar código del objetivo
  si no hay sandbox del sistema operativo. Sin sandbox, el estado correcto es
  `needs_validation`.
- REA nunca ejecuta el artefacto analizado como proceso del host.

---

## Estructura

```
atomo/
├── core/                  # portable entre harnesses
│   ├── AGENTS.md          # reglas + tabla de capacidades
│   ├── mcp.json           # definición neutral de servidores
│   └── skills/            # formato SKILL.md estándar
├── agents/                # OpenCode: átomo, reviewer, verifier, planner
├── commands/              # OpenCode: /review, /commit, /explain, /capacidades
├── harnesses/             # una guía por harness
├── install/               # bootstrap e instalador de OpenCode
├── verify/                # oc-capabilities
└── docs/                  # arquitectura, seguridad, troubleshooting
```

---

## Limitaciones conocidas

- **La elección de herramienta es del modelo.** Dos ejecuciones de la misma petición
  pueden elegir distinto. La tabla reduce la varianza; no la elimina.
- **Sin sandbox no hay confirmación de exploits.** Es una decisión de diseño, no un fallo.
- **Ghidra y JADX son pesados.** En 3,7 GB de RAM funcionan, pero con un subagente a la vez.
- **graphify** solo aporta en repos grandes o corpus mixtos. En un proyecto pequeño,
  `grep` gana.

---

## Créditos

- [REA](https://github.com/heretek-ai) — análisis de artefactos.
- [Ghidra](https://ghidra-sre.org/) — NSA.
- [JADX](https://github.com/skylot/jadx) — skylot.
- [security-audit](https://github.com/cloudflare/security-audit-skill) — Cloudflare, MIT.
- [SofIA](https://github.com/OpsafyMX/opsafy-skills) — Opsafy, MIT.
- [graphify](https://github.com/Graphify-Labs/graphify) — Apache-2.0.

Ver [`NOTICE.md`](NOTICE.md) para atribuciones completas.

## Licencia

MIT para el contenido propio. Las skills de terceros conservan su licencia original.

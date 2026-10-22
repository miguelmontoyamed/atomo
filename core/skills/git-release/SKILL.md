---
name: Git Release
description: Preparar un commit o un release con historial limpio, versionado y notas verificables
---

# Git Release

Usa esta skill cuando haya que **commitear**, **versionar** o **publicar** un cambio.

Lee `references/release-policy.md` para las reglas de versionado y firma de commits.

## Procedimiento

### A. Commit

1. **Inspecciona antes de tocar**: `git status --porcelain`, `git diff --staged`, `git log --oneline -10`.
   Si no es un repo git, dilo y no inicialices nada sin permiso.
2. **Separa por intención.** Un commit = un cambio lógico. Si hay cambios independientes
   (feature + fix de typo + refactor), sepáralos en commits distintos con `git add -p`.
3. **Verifica que no entra basura**: `.env`, artefactos de build, credenciales, archivos
   temporales, `node_modules`. Si aparecen, avisa antes de commitear.
4. **Escribe el mensaje** en formato convencional:

```
<tipo>(<alcance opcional>): <resumen en imperativo, <=72 chars>

<por qué del cambio, no qué cambió>

<pie opcional: refs, breaking change>
```

   Tipos: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`.
5. **Commit.** Nunca `--no-verify` salvo petición explícita. Nunca `--amend` sobre un
   commit ya publicado.

### B. Release

1. **Comprueba el estado**: rama actual, si está limpia, si está al día con el remoto,
   y qué etiquetas existen (`git tag --sort=-v:refname | head`).
2. **Decide la versión** según `references/release-policy.md` (semver).
3. **Genera las notas desde el historial real**, no de memoria:
   `git log --oneline <última_tag>..HEAD`. Agrupa por tipo. Omite ruido de merge.
4. **Anota breaking changes primero**, con la migración necesaria.
5. **Etiqueta**: `git tag -a vX.Y.Z -m "vX.Y.Z"` y publica con `git push origin main --follow-tags`.
6. **No publiques** paquetes, imágenes o binarios sin confirmación explícita del usuario.

## Reglas

- Nunca `git push --force` sobre una rama compartida. Si hace falta, usa `--force-with-lease` y avisa.
- Nunca reescribas historia ya publicada sin pedirlo.
- Si el repo tiene hooks (husky, pre-commit), ejecútalos; no los desactives.
- Si el usuario pide "commitear todo", verifica igualmente que no haya secretos. Un commit
  con una clave filtrada es irreversible en la práctica.
- Cita `archivo:línea` cuando expliques qué entra en cada commit.

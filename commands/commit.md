---
description: Preparar y crear un commit con mensaje convencional
---

Prepara un commit para los cambios actuales.

1. Inspecciona `git status --porcelain`, `git diff` y `git log --oneline -10`.
2. Verifica que no haya secretos ni artefactos de build en el staged.
3. Si los cambios tienen intenciones distintas, propón separarlos en varios commits y
   espera confirmación.
4. Propón el mensaje en formato convencional (`tipo(alcance): resumen`).
5. Crea el commit.

$ARGUMENTS

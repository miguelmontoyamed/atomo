---
description: Revisar el diff actual o los archivos indicados
agent: reviewer
---

Revisa $ARGUMENTS.

Si no se indicó nada, revisa el cambio pendiente: usa `git diff` y `git diff --staged`.
Si no es un repo git, pide los archivos concretos.

Aplica la skill `code-review` y su checklist. Salida ordenada por severidad, cada hallazgo
con `archivo:línea`, impacto y arreglo mínimo. Termina con la sección `Sin cubrir`.

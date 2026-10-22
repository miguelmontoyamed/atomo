---
name: Code Review
description: Revisar código o un diff con un checklist de correctitud, seguridad, concurrencia y tests
---

# Code Review

Aplica este checklist cuando revises código. Lee `references/checklist.md` para el detalle de cada punto.

## Procedimiento

1. **Establece el alcance.** ¿Qué cambió y qué depende de ese cambio? Si no hay diff disponible, usa `git diff` o `git diff --staged`; si no es un repo git, pide los archivos.
2. **Lee el contexto.** Al menos la función completa y sus llamadores. No revises líneas sueltas.
3. **Recorre el checklist** en `references/checklist.md`, en orden de prioridad.
4. **Clasifica** cada hallazgo: `crítico` (rompe o compromete), `alto` (bug probable), `medio` (deuda o fragilidad), `bajo` (estilo).
5. **Propón el arreglo mínimo** por hallazgo. No reescribas la arquitectura salvo que el hallazgo lo exija.

## Reglas

- Un hallazgo sin `archivo:línea` no es un hallazgo.
- Separa observación (`el código hace X`) de inferencia (`esto podría fallar si Y`).
- Si no hay hallazgos, dilo. Un review vacío es válido.
- No comentes estilo si el proyecto tiene un formatter que ya lo cubre.
- No propongas cambios que no puedas explicar con el código que viste.

## Salida

```
VEREDICTO: aprobar | aprobar con cambios | rechazar

[crítico] ruta/archivo.ts:142 — <qué está mal>
  Por qué: <impacto>
  Arreglo: <cambio mínimo>

[alto] ...
```

Al final, una sección `Sin cubrir` con lo que no pudiste verificar y por qué.

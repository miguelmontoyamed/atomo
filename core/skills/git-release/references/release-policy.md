# Política de versionado y release

## Semantic Versioning

`MAJOR.MINOR.PATCH`

| Cambio | Bump | Ejemplos |
|---|---|---|
| Rompe compatibilidad | MAJOR | quitar una opción de CLI, cambiar el formato de un archivo de config, cambiar el tipo de retorno de una API pública |
| Añade funcionalidad compatible | MINOR | nueva opción, nuevo endpoint, nueva exportación |
| Solo corrige | PATCH | bug fix sin cambio de contrato, typo en un mensaje, parche de seguridad compatible |

Pre-1.0: el criterio habitual es que MINOR puede romper. Si el proyecto lo declara en su
README o CHANGELOG, esa regla manda sobre esta.

## Qué cuenta como cambio público

- API exportada (funciones, clases, tipos, endpoints, canales IPC).
- Formato de datos en disco o en red.
- Variables de entorno y flags de CLI.
- Requisitos mínimos (versión de runtime, dependencias del sistema).

Un cambio en cualquiera de estos es público aunque el código sea interno.

## Formato de las notas

```markdown
## v1.4.0

### Breaking
- `foo()` ya no acepta `bar: string`; usar `baz: Options`. (#123)

### Añadido
- ...

### Corregido
- ...

### Interno
- ...
```

## Reglas de commit

- Un commit, una intención. Si el mensaje necesita "y", probablemente son dos commits.
- El asunto en imperativo: `añade`, no `añadido` ni `añadiendo`.
- El cuerpo explica **por qué**, no repite el diff.
- Referencia el issue cuando exista: `Refs: #42` o `Closes: #42`.
- Breaking change: línea `BREAKING CHANGE: <qué> → <migración>` en el pie.

## Antes de etiquetar

- [ ] Árbol limpio y rama al día con el remoto.
- [ ] Tests en verde (delegar en `verifier` si está disponible).
- [ ] CHANGELOG actualizado si el proyecto lo mantiene.
- [ ] Versión en los manifiestos coherente (`package.json`, `pyproject.toml`, `Cargo.toml`).
- [ ] Sin secretos: `git diff <última_tag>..HEAD | grep -iE 'key|token|secret|password'` como mínimo.

## Errores comunes

- Etiquetar un commit que no está en la rama publicada.
- Publicar con el árbol sucio y que el artefacto no corresponda al tag.
- Reutilizar un tag ya empujado: imposible sin `--force`, y rompe a quien ya lo descargó.

# Instrucciones para GitHub Copilot

## Idioma
- Responde siempre en español.
- Los mensajes de commit van en español.

## Commits (obligatorio)

Cuando propongas un commit, DEBES cumplir TODAS estas reglas:

1. **Longitud máxima**: 50 caracteres. Si no cabe, el commit está mal.
2. **Modo imperativo**: usa "agrega", "crea", "corrige", "elimina".
   - ❌ "agregué", "agregando", "se agregó"
3. **Un solo tema por commit**: si hay cambios de dos temas, sepáralos en dos commits.
4. **Formato obligatorio**: `tipo: descripción breve`
   - Tipos permitidos: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`
5. **Sin punto final** en el mensaje.
6. **Sin mayúscula inicial** después de los dos puntos.

### Ejemplos válidos
- `feat: agrega estilos responsive`
- `docs: crea reglas de commit para agente`
- `fix: corrige enlace roto en footer`
- `style: mejora contraste de titulos`

### Ejemplos inválidos
- `Añadí CSS y también cambié el HTML` (dos temas, pasado, >50)
- `feat: Agrega estilos responsive.` (mayúscula y punto)
- `update` (sin tipo, sin descripción)

## Flujo de trabajo que DEBES seguir

1. **Antes de proponer un commit**, muéstrame el resultado de `git diff --staged`.
2. **Propón un solo mensaje de commit** que cumpla las reglas anteriores.
3. **Si detectas varios temas** en los cambios, propón varios commits separados.
4. **No ejecutes `git commit`** sin que yo lo confirme.
5. **No modifiques archivos** sin mostrarme primero el plan.

## Código

- No agregues comentarios innecesarios.
- No cambies texto, estructura HTML ni contenido existente si no te lo pido.
- Usa CSS puro, sin frameworks externos, salvo que lo indique.
- Mantén el HTML semántico (`header`, `main`, `section`, `article`, `footer`).

## Al generar un Pull Request

- **Título**: mismo formato que un commit (`tipo: descripción breve`, ≤ 50 caracteres).
- **Descripción**: lista de cambios en viñetas.
- **Obligatorio incluir** una línea final con este formato:
- **Revisión humana:** qué hizo bien el agente y qué tuve que corregir.
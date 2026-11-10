---
name: managing-github-issues
description: Use when creating, breaking down, updating, or closing GitHub issues for tracking, bug reports, and task management
---

# Gestión y Seguimiento de Issues en GitHub

## Visión General
Esta habilidad define el estándar riguroso para planificar, redactar, descomponer, seguir y cerrar issues en repositorios de GitHub. Garantiza coherencia arquitectónica, redacción técnica impecable en español, trazabilidad de tareas y control explícito por parte del usuario.

## Cuándo Usar
- Al descomponer una especificación, plan de implementación o requerimiento en tareas independientes.
- Al documentar un bug, deuda técnica o propuesta de refactorización.
- Al dar seguimiento al progreso de tareas mediante la actualización de listas de verificación y comentarios.
- Antes de vincular o cerrar issues asociadas a Pull Requests o revisiones.

## Cuándo NO Usar
- Para notas personales o listas temporales que no pertenezcan al repositorio.
- Para tareas triviales de una sola línea que ya se estén ejecutando de manera inmediata en la sesión actual.

## Reglas Obligatorias de Redacción y Codificación
1. **Español Técnico y Corrección Gramatical:**
   - Todo el contenido debe estar redactado en español con ortografía rigurosa.
   - Es obligatorio el uso correcto de tildes ortográficas y diacríticas.
2. **Sanitización y Codificación Limpia:**
   - Prohibido el uso de entidades HTML escapadas (como `&quot;`, `&#34;`, `\u0026#34;`) o caracteres de control incompatibles (`\u0007`). El texto debe ser UTF-8 plano y legible.
   - Las citas de código y rutas deben presentarse en formato de bloques Markdown limpios.

### Verificación de Idioma Antes de Presentar el Borrador

Obligatoria en cada borrador. Releer el título y el cuerpo completo, no solo la sección de Diagnóstico.

**Comprobación mecánica:** correrla además de la lectura; la lectura a ojo ya dejó pasar errores en la ronda previa.

```powershell
$t = [IO.File]::ReadAllText($ruta, [Text.UTF8Encoding]::new($false))
$t -match '[\u0370-\u03FF\u0400-\u04FF\u0590-\u06FF\u0900-\u0D7F\u3040-\u30FF\u4E00-\u9FFF\uFF00-\uFFEF]'
```

Devuelve `True` si hay caracteres no latinos (griego, cirílico, hebreo, árabe, devanagari, kana, CJK, ancho completo). No marca `á é í ó ú ü ñ ¿ ¡` ni puntuación española.

1. **Caracteres no latinos:** ningún carácter fuera del alfabeto latino (`á é í ó ú ü ñ ¿ ¡`), incluidos los que se cuelan en lugar de una letra o forma verbal — grafías cirílicas o griegas con apariencia latina, signos de ancho completo. Prestar atención particular a las tildes de sustantivos, verbos, adjetivos y adverbios (`fácil`, `también`, `más`).
2. **Palabras inexistentes:** cualquier palabra que no figure en un diccionario del español ni en el léxico técnico habitual del proyecto está mal, aunque suene verosímil.
3. **Concordancia:** verificar verbo y sujeto en cada oración de Diagnóstico, Evidencia y Propuesta. Los conectores (`sin embargo`, `además`, `por lo tanto`) van seguidos de coma.
4. **Idioma ajeno:** ningún término en inglés u otro idioma fuera de los anglicismos consolidados del léxico técnico del proyecto (`issue`, `pull request`, `commit`, `diff`, `build`, `label`) ni de los nombres propios de tecnologías. Las rutas de archivo, las claves de objeto y cualquier identificador se citan entre comillas invertidas.

Los bloques de código con rutas, comandos y snippets quedan **intactos**: la revisión no debe reinterpretar contenido técnico. Si un bloque contiene un comentario en otro idioma, se señala pero no se reescribe sin aprobación.

Si el defecto se detecta en el borrador, corregirlo antes de presentarlo. Si la issue ya existe, corregir el cuerpo y registrar la corrección como tarea en esa issue, nunca como issue nueva.

## Estándar de Títulos
Los títulos deben seguir el formato de Conventional Commits o prefijos de dominio consolidados:
`type(scope): descripción concisa en minúsculas`

- **Tipos permitidos:** `feat`, `fix`, `refactor`, `style`, `perf`, `test`, `docs`, `chore`, `architecture`.
- **Reglas del título:**
  - En minúsculas y sin punto final.
  - Verbo en infinitivo o sustantivo descriptivo de la acción (`normalización de...`, `implementación de...`, `configurar modo...`).
  - Uso obligatorio de tildes cuando corresponda gramaticalmente.

## Descomposición de Tareas

### 1. Slices Verticales (Tracer Bullets)
- Cada issue debe representar una rebanada vertical completa que atraviese todas las capas necesarias (Base de datos → API / Backend → UI / Frontend → Tests).
- Evitar particiones horizontales aisladas (por ejemplo, una issue para "hacer tablas de BD" y otra para "hacer pantallas"), salvo casos justificados de infraestructura base.
- Cada slice completada debe ser verificable y entregable de forma autónoma.

### 2. Patrón Expand–Contract (Refactorizaciones Amplias)
Cuando un cambio afecte transversalmente a gran parte de la base de código (*blast radius* amplio), estructurar en tres fases:
1. **Expandir (Expand):** Introducir la nueva implementación en paralelo sin alterar ni romper la funcionalidad existente.
2. **Migrar (Migrate):** Migrar los puntos de llamada en lotes controlados (cada lote como una issue independiente con tests verdes).
3. **Contraer (Contract):** Eliminar la implementación antigua una vez que ninguna referencia dependa de ella.

### 3. Clasificación de Autonomía
Cada issue debe etiquetarse con su nivel de autonomía:
- **`[AFK]` (Away From Keyboard):** Tarea completamente especificada con criterios claros, ejecutable por un agente sin requerir consultas intermedias.
- **`[HITL]` (Human In The Loop):** Tarea que involucra decisiones de diseño, selección de alternativas visuales o validaciones comerciales que exigen retroalimentación continua del usuario.

## Plantilla Estándar del Cuerpo de la Issue

```markdown
## Diagnóstico / Problema
Descripción clara del comportamiento anómalo, limitación técnica o requerimiento funcional.

## Evidencia / Causa
- Rutas exactas de archivos y líneas relevantes: `ruta/al/archivo.ts:L10-L25`.
- Snippets o referencias directas a decisiones arquitectónicas previas.
- Comportamiento observado vs. comportamiento esperado.

## Propuesta / Solución
Enfoque técnico acordado para resolver el problema o implementar la funcionalidad.

## Criterios de Aceptación
- [ ] Criterio verificable 1.
- [ ] Criterio verificable 2.
- [ ] Pruebas automatizadas añadidas o actualizadas.
- [ ] Verificación de compilación exitosa (`build` verde).

## Tareas a Realizar
- [ ] Tarea concreta 1.
- [ ] Tarea concreta 2.

## Dependencias
- **Bloqueado por:** #ID o "Ninguno - listo para comenzar".
- **Clasificación:** `[AFK]` o `[HITL]`.
```

## Taxonomía de Etiquetas (Labels)

**Conjunto cerrado y canónico (nombres SIEMPRE en inglés).** Estas son las labels que existen
hoy en `ignaciorevainera/correo-argentino-mda`. **No crees labels nuevas**: si el trabajo no
encaja en ninguna, presentá la propuesta (nombre + color + descripción) al usuario y esperá su
aprobación explícita. Antes de etiquetar, verificá la lista real con `github_ui_get`
(`method: "labels"`) para no trabajar con datos viejos.

- **Tipo / tratamiento:** `bug`, `enhancement` (feat, mejora, nuevo requerimiento), `refactor`, `test`, `style`, `performance`, `documentation`, `chore`.
- **Dominio / área:** `ui/ux`, `database`, `architecture`, `security`.
- **Estado / prioridad:** `high-priority`, `epic`, `tech-debt` (deuda técnica), `finding` (hallazgo no bloqueante).
- **GitHub por defecto (solo si aplica):** `duplicate`, `invalid`, `question`, `wontfix`, `help wanted`, `good first issue`.

**Equivalencias y nombres ya fuera de circulación:**

- `hallazgo` → **`finding`** · `deuda-tecnica` → **`tech-debt`** · `mejora` → **`enhancement`** (la label `mejora` fue eliminada por redundante).
- Nombres que **no existen** y deben evitarse: `feature` → `enhancement`; `testing` → `test`; `api` → `architecture` o `database`; `navigation` → `architecture`; `blocked` / `needs-discussion` → usar el cuerpo de la issue en vez de label.

## Protocolo Estricto de Ciclo de Vida y Aprobación

```
[Redactar Borrador] ──> [Presentar al Usuario] ──> [Aprobación Explícita] ──> [Crear Issue]
                                                                                     │
                                                                                     ▼
[Cerrar Issue] <── [Aprobación Explícita] <── [Validar 100% Criterios] <── [Actualizar Avances]
```

1. **Creación:**
   - Prohibido crear issues de manera directa mediante herramientas o MCP sin confirmación.
   - Siempre presentar el borrador (título, cuerpo completo y etiquetas propuestas) y esperar la autorización explícita del usuario.
2. **Actualización:**
   - Marcar las casillas de verificación (`- [x]`) conforme se verifique el avance.
   - Añadir comentarios de seguimiento con evidencia de ejecución (salida de pruebas, capturas o diffs relevantes).
3. **Cierre:**
   - Solo se puede proponer el cierre cuando el 100% de los criterios de aceptación y tareas estén cumplidos.
   - Prohibido cerrar la issue de forma automática; se debe solicitar y obtener la aprobación explícita del usuario para ejecutar el cierre.
   - En los Pull Requests asociados, vincular la issue con la sintaxis de cierre oficial (`fixes #ID` o `closes #ID`).

## Banderas Rojas y Racionalizaciones

| Excusa o Racionalización | Realidad |
| :--- | :--- |
| "Es solo texto en markdown, no importan las tildes" | La calidad técnica y profesional exige ortografía impecable en español. |
| "Es una tarea simple, la creo directo sin mostrar borrador" | Ninguna issue se crea sin previa validación y aprobación del usuario. |
| "El PR ya se fusionó, cierro la issue automáticamente" | Se requiere verificación completa de criterios y confirmación del usuario para cerrar. |
| "Hago una sola issue enorme para todo el módulo" | Las issues deben dividirse en rebanadas verticales manejables y autónomas. |

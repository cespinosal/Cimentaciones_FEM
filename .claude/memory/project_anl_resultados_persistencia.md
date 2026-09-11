---
name: project-anl-resultados-persistencia
description: lastVuCriticoAnl/lastMuDisenoAnl (fuente de 5.4/5.3 tras importar .ANL) no sobrevivían a guardar/reabrir .gfem — corregido 11/09/2026
metadata: 
  node_type: memory
  type: project
  originSessionId: f861cbdf-631a-4eea-8d78-60656599a932
  modified: 2026-09-11T20:55:36.109Z
---

Bug encontrado y corregido el 11/09/2026 (commit `d1a96e6`): los resultados del último `.ANL`
importado que alimentan **5.4** (cortante por dado, `lastVuCriticoAnl`) y **5.3** (envolvente
Wood-Armer, `lastMuDisenoAnl`) vivían solo en variables de módulo (`let`, fuera de `state`), así que
se perdían al reabrir un `.gfem` guardado — la revisión caía de vuelta al criterio viejo (pico
global de la tabla 5.1 / peor de las 16 filas) sin ningún aviso de que se había perdido la fuente
"oficial" por `.ANL`.

**Por qué importa:** el usuario detectó una diferencia real de % de eficiencia en 5.4 entre dos
sesiones (98%→108%) que en realidad era por haber reimportado un `.ANL` corregido (el anterior tenía
un aviso de placas no coincidentes) — no un bug. Pero al investigar se encontró este problema real de
persistencia, separado de esa confusión.

**Cómo se corrigió:** se agregó `state.anlResultados = {vuCritico, muDiseno}` a `defaultState()`
(mismo patrón que `brazoCache`/`areaEfectivaCache`, ver comentario ahí). Se escribe en paralelo a las
variables de módulo dentro de `importarElementosMecanicosDesdeAnl()`, se restaura desde `state` en
`loadProjectFromFile()` y `btnReset` (ANTES de los `renderAll()`), y se limpia junto con
`state.elementosMecanicos` en el botón "limpiar tabla 5.1".

**Cómo aplicar:** si aparece otra fuente de datos "oficial" derivada de un import (STAAD, PDF, etc.)
que solo viva en una variable de módulo `let lastX = null`, hay que preguntarse desde el principio si
debería espejarse en `state` para sobrevivir al `.gfem` — no asumir que basta con que sea legible
durante la sesión. Ver [[project_sin_persistencia_localstorage]] para el contexto de que esta app NO
persiste sola en localStorage (a propósito): `.gfem` es la única forma de conservar trabajo entre
sesiones, así que cualquier resultado "bueno" que no viva en `state` se pierde silenciosamente ahí.

Verificado con Playwright headless (`?dev=1`): se armó un `.gfem` sintético con `anlResultados`
poblado a partir del estado de ejemplo, se cargó vía `#fileImport`, y se confirmó que 5.3/5.4 muestran
la fuente por `.ANL` restaurada en vez de caer al criterio viejo.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Cimentaciones FEM — herramienta web (en español) para el diseño de zapatas/losa general de torres
autosoportadas (3 y 4 patas) y monopolos, portada de una hoja de cálculo Excel de American Tower
(`XXXXXX _ Losa General _ V1.7.xlsm`, incluida en el repo como referencia de las fórmulas fuente).
La app vive en dos archivos autocontenidos: **`index.html`** (la herramienta, ~8500 líneas) y
**`help.html`** (documentación de usuario, abierta en pestaña nueva desde el botón "Ayuda" del
topbar). No hay build, ni bundler, ni `package.json`.

## Flujo de trabajo — IMPORTANTE, leer antes de empezar

Este repo se trabaja desde dos máquinas distintas (ver `WORKFLOW.md` para el detalle completo de
conexión): una casa (clon directo) y una VM de Oracle Cloud a la que se accede por VS Code
Remote-SSH (esta sesión de Claude Code normalmente corre ahí, en `~/Hoja-FEM`).

**Regla de oro: `git pull` antes de tocar nada, `git push` antes de terminar.** Git no sincroniza
solo entre las dos máquinas — si alguno de los dos lados se salta un paso, el otro se queda
trabajando sobre una versión vieja sin darse cuenta (ya pasó: la copia de esta VM llegó a estar 4
commits atrás de `origin/main`, incluyendo el archivo `help.html` completo, sin ningún error visible
hasta hacer `git fetch`). Si `git pull` marca conflicto o "diverging branches", parar y avisar antes
de forzar nada.

## Running / developing

- No build step. Abrir `index.html` (o `help.html`) directamente en el navegador (funciona por
  `file://`, sin servidor).
- No hay tests ni linter configurados en el repo.
- El estado del formulario se persiste en `localStorage` (`cimentacionesFEM.v1`); para probar desde
  cero, limpiar el storage del sitio o usar una ventana de incógnito.
- Botón "Restaurar geometría de ejemplo" (`btnReset`) reinicia a `exampleState()`. Exportar/importar
  el estado completo como archivo `.gfem` (JSON) con los botones de import/export.

## Arquitectura de `index.html`

`<style>` (tokens de diseño Fluent 2 replicados en CSS puro) + marcado de las pestañas + un único
`<script>` en IIFE al final (`(function(){ "use strict"; ... })()`), organizado en bloques numerados
delimitados por banners `/* ==== N. NOMBRE ==== */` (`grep -n "===="` para navegar el archivo).

Bloques principales, en orden:
1. **Motor de propiedades de sección** — shoelace generalizado sobre polígonos con soporte de
   huecos (área, centroide, Ix/Iy/Ixy, ejes principales, módulos elásticos y plásticos). Puerto
   directo del algoritmo de `Shapebuilder` (herramienta Python separada del usuario,
   `core/section_properties.py`), verificado numéricamente contra la hoja Excel original.
2. **Estado** (`state`, `TOWER_TYPES`, `defaultState()`/`mergeState()`/`loadFromStorage()`/
   `saveToStorage()`) — ver "Estado y persistencia" abajo.
3. Validación de rangos físicos razonables (avisa, no bloquea).
4. Tablas de vértices + import de vértices desde AutoCAD (`.txt` de `SHAPEPTS.lsp`).
5. Geometría de dados (réplica de fórmulas `Cálculo!X4:Z6` y `X11:AC33` del Excel).
6. Render SVG en planta.
7-8. Render de propiedades y de dados; **8.1 Diseño geotécnico** (resistencia/volteo, fórmulas 1:1
   de la hoja "Cálculo" filas 52-83, dado adaptado de cuadrado `AD²` a rectangular `AD×LD`) y
   **4.3 revisión por capacidad de carga** (ley de Navier:
   `τ(x,y) = RFY_Total/Área − Mx_Total·y/Ix + Mz_Total·x/Iy`, con animaciones de Brazo de palanca y
   Área efectiva por combo, disparadas por clic).
9. Render general / bindings, tabla de reacciones, importación de reacciones desde PDF.
   **Diagrama de interacción P-M-M biaxial** (pestaña "Interacción 3D", ACI 318-19 Cap. 22 por
   compatibilidad de deformaciones — cálculo interno en kg/cm, salida en Tn/Tn-m) y **Acero 3D**
   (pestaña con escena Three.js propia e independiente de la de "Cálculos", vista del refuerzo con
   longitudes de desarrollo ACI) van al final del archivo.

Cada sección de fórmulas lleva en su comentario de cabecera la referencia exacta a la hoja/celdas
del Excel fuente que porta, o a la norma (TIA-222-H, ACI 318-19) cuando la fórmula ya no viene del
Excel — mantenerlo así al modificar o agregar fórmulas nuevas.

### Estado y persistencia

- `state` es un único objeto global, persistido completo en `localStorage` en cada `saveToStorage()`
  (llamado al final de `renderAll()`).
- `mergeState(defaults, saved)` combina el guardado con `defaultState()` para tolerar versiones
  viejas del estado. El merge de nivel superior **no** alcanza subobjetos anidados: `geom`,
  `materiales`, `angles` y `proyecto` se fusionan aparte explícitamente — un campo nuevo dentro de
  esos subobjetos no requiere tocar `mergeState`, pero sí agregarlo a `defaultState()`.
- `renderAll()` es el único punto de recálculo/redibujado: recalcula propiedades de sección,
  geometría de dados, geotécnico, capacidad portante, malla FEM, diseño estructural, y vuelve a
  pintar todo el DOM. Cualquier cambio de `state` que deba reflejarse en pantalla debe terminar en
  una llamada a `renderAll()` (las ediciones de texto libre usan `setValueIfNotFocused` para no
  robar el foco mientras se tipea, sin disparar un render completo).
- La pestaña activa **no** se persiste a propósito: cada carga siempre arranca en "Revisiones".

### Pestañas (tabs) de `index.html`

`Revisiones` (historial) → `Definición de la zapata` (vértices, hueco, planta, propiedades) →
`Reacciones` (tabla por combo × pata, o por punto único en monopolos) → `Cálculos` (nav lateral
autogenerado desde las `section.card` presentes: elementos mecánicos, materiales, geometría/vista
3D, 4.1-4.3 geotécnico, 4.4 mallado "Urdimbre Mesh", 4.5 Coeficiente de Balasto, 4.6 Propiedades de
Concreto, 4.7 export a STAAD.Pro, 5.1-5.6 Diseño Estructural ACI 318-19, 6 resumen de eficiencias) →
`Interacción 3D` (diagrama P-M-M del dado, vía Plotly) → `Acero 3D` (vista 3D del refuerzo) →
`Motor FEM` (documentación de referencia normativa + roadmap del motor FEM interno, sin
interactividad).

`TOWER_TYPES` define, por tipo de estructura, la forma de la tabla de reacciones: `kind:"legs"`
(Autosoportada 3P/4P, combos × patas) vs `kind:"base"` (Monopolo, combos × un solo punto de apoyo).
`"M4"` es alias de `"Autosoportada 4P"` (`REACTION_TYPE_ALIAS`), no una configuración aparte.

### Diseño estructural (sección 5) y export a STAAD (sección 4.7)

- La malla FEM ("Urdimbre Mesh", sección 4.4) es hoy solo una previsualización visual: grilla
  regular sobre el interior + triangulación de Delaunay restringida en huecos/esquinas/dados,
  recombinada en cuadriláteros y reparada localmente (suavizado/reconexión/fusión de elementos
  diminutos). No corre análisis FEM adentro de la app todavía — eso es el objetivo pendiente de la
  pestaña "Motor FEM".
- El **modelo `.STD` para STAAD.Pro** (sección 4.7) sí se genera completo (geometría, malla,
  materiales, apoyos con coeficiente de balasto, estados de carga con reacciones por combo). Reglas
  a respetar si se toca el generador: convención de ejes `Staad(X,Y,Z) = FEM(X,-Z,Y)`, normales de
  cada shell por regla de la mano derecha, formato numérico a 6 decimales limpiando ruido de punto
  flotante (`fmtStaadNum`), y el límite de 79 caracteres por línea — **misma convención que
  `TSA/viewer.html`**, otro proyecto del usuario.
- La **sección 5 (Diseño Estructural)** referencia ACI 318-19 directamente (no copia el Excel
  original, que tenía errores encontrados en auditoría: fórmula de ρ sin el factor 0.85, β1 con
  coeficiente equivocado, φ de punzonamiento sin usar, Ast/Ag asumiendo dado cuadrado). Cubre:
  momento de diseño por Wood-Armer fila a fila (5.3), cortante en una dirección por eje X/Y (5.4),
  punzonamiento con Vu real = reacción del dado menos presión de suelo (5.5), revisión axial del
  dado con esquema 2D de armado (5.6), y resumen de eficiencias de toda la hoja (sección 6). Los
  datos de entrada (momentos/cortantes por franja) son manuales, copiados de la malla de placas que
  exporta STAAD.

### Librerías externas

- **PDF.js 4.10.38** y **Three.js r0.128 + OrbitControls**: código fuente completo pegado inline en
  `<script type="application/octet-stream" id="...">` (no se ejecuta como script normal), cargado en
  runtime vía Blob URL + `import()` dinámico — sin CDN, para funcionar 100% offline. El código
  relevante para PDF o vista 3D está en esos bloques, no en un `node_modules`.
- El contenido de `SHAPEPTS.lsp` también está embebido como string (`SHAPEPTS_LSP`) para ofrecer su
  descarga directa desde la app; si se edita el `.lsp` del repo, actualizar también esa copia
  embebida.
- **Excepción**: `Plotly` (para el diagrama de Interacción 3D) se carga desde CDN
  (`cdn.plot.ly/plotly-2.35.2.min.js`), rompiendo a propósito el patrón "sin CDN" de las demás
  librerías — tenerlo en cuenta si se necesita que la app funcione sin conexión a internet.

## `help.html`

Documentación de usuario autocontenida (sidebar + navegación por scroll, FAQ en acordeón, glosario,
historial de versiones) — **su contenido debe mantenerse verificado contra el `index.html` real**
(nombres exactos de campos/pestañas, unidades, alcance realmente implementado vs. pendiente). Si se
agrega o renombra una pestaña/campo en `index.html`, revisar si `help.html` quedó desactualizado.

## Flujo de datos con herramientas externas

- **AutoCAD → app**: `SHAPEPTS.lsp` (cargado en AutoCAD con `APPLOAD`) expone `SHAPEPTS` (clic a
  clic) y `SHAPEPLINE` (desde polilínea o círculo ya dibujado), exporta un `.txt` con una línea
  `x,y` por vértice — mismo formato que usa Shapebuilder. Se importa en "Definición de la zapata"
  (contorno exterior y hueco); las coordenadas nunca se editan a mano, solo se importan o se borran.
- **Reporte de reacciones (PDF) → app**: pestaña "Reacciones", importación automática vía PDF.js
  leyendo texto con coordenadas de página (no texto plano) para reconstruir la tabla
  Radius/Elevation/Azimuth/Nodo/FX/FY/FZ.
- **App → STAAD.Pro**: sección 4.7 exporta el `.STD` completo; el análisis se corre externamente en
  STAAD y sus resultados de placas (momentos/cortantes) se reingresan a mano en la sección 6 para el
  diseño estructural ACI 318-19.
- **Excel fuente**: `XXXXXX _ Losa General _ V1.7.xlsm` (hoja "Cálculo") es la referencia
  autoritativa de las fórmulas geotécnicas/geométricas; los PDFs en `Reacciones - Ejemplos/` son
  reportes de reacciones reales usados para probar el importador de PDF.

## Alcance / roadmap (según pestaña "Motor FEM")

Ya cubierto: geometría y propiedades de sección, reacciones (manual + import PDF), geotécnico por
volteo y capacidad portante (TIA-222-H), previsualización de malla FEM, export completo a
STAAD.Pro, diseño estructural por ACI 318-19 (flexión, cortante, punzonamiento, dado, resumen de
eficiencias), interacción P-M-M del dado y vista 3D de acero. Pendiente: correr el análisis FEM
directamente dentro de la app usando la malla "Urdimbre Mesh" ya generada, para dejar de depender de
exportar a STAAD.Pro y analizar por fuera.

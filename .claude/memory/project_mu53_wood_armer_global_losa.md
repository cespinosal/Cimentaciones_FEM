---
name: project-mu53-wood-armer-global-losa
description: "5.3 (Mu): envolvente Wood-Armer ahora busca en toda la losa (no solo cerca del dado); limitación conocida por ejes locales de STAAD no alineados en zonas de malla irregular, medida y acotada (09/09/2026)."
metadata:
  type: project
  modified: 2026-09-09T00:00:00.000Z
---

**Cambio (09/09/2026):** con un `.ANL` importado, el momento de diseño Mu de 5.3 (flexión) ya no
sale del peor de las 16 filas de la tabla 5.1 (aproximación) — sale de `lastMuDisenoAnl`
(`calcularMuDisenoDesdeAnl`, index.html ~línea 16632), que evalúa Wood-Armer directo con el
Mx/My/Mxy simultáneo de CADA placa/combo del `.ANL`, buscando en **toda la malla** (sin
restringir a la banda cerca del dado), y se queda con el máximo real. `getMomentosDisenoFlexion`
(línea 6106) usa `lastMuDisenoAnl` como fuente oficial; si es null (sin `.ANL`), cae al criterio
anterior sobre `state.elementosMecanicos`.

De paso cambió el `scope` de `ANL_CAMPO_INFO` (línea 12919): Mx/My/Mxy/Sx/Sy/Sxy ahora buscan su
Max/Min de la tabla 5.1 en TODA la losa ("global"); Qx/Qy siguen restringidos a la banda b0 cerca
del dado ("b0", porque cortante en una dirección SÍ tiene una sección crítica a distancia fija —
ACI 318-19 §22.5.5.1.2 — y el momento no). Decisión explícita del usuario: "el momento flector lo
ibamos a buscar en toda la losa. Y hacer wood-armer".

**Limitación conocida, investigada y acotada (09/09/2026):** el eje local `x` de cada plate en
STAAD (el que determina qué es Mx vs My, ver `orientarNormalArribaStaad`/
`rotarInicioAbajoIzquierdaStaad`) solo coincide con el eje global X/Y en la grilla regular de la
malla ("Urdimbre Mesh", bloque 4.4) — en los cuadriláteros/triángulos de relleno que salen de la
triangulación de Delaunay en zonas de transición (huecos, esquinas, dados) puede quedar rotado.
Si el pico real de Mu cae justo en uno de esos elementos, Wood-Armer combinando el Mx/My LOCAL sin
transformar a global puede sobre/subestimar el momento real en la dirección real del armado.

Medido con una prueba headless de Playwright contra `index.html` real (geometría de ejemplo,
hexágono irregular 3P, 5453 elementos/54.4 m²), comparando el eje local de cada elemento (mismas
funciones que usa el export a STAAD) contra el global:
- 98.5% del área es grilla regular, desalineamiento promedio 0.84° — ahí Mx/My SÍ son confiables.
- Solo ~2.9% del área tiene el eje local desviado más de 15° del global; concentrado en
  triángulos de relleno del BORDE EXTERIOR/esquinas de la losa (elementos chicos, muy por debajo
  del tamaño nominal de malla), no cerca de los dados.
- La banda b0 (cerca de los dados, donde antes SÍ se buscaba Mx/My) tiene, si acaso, un
  desalineamiento promedio ligeramente MAYOR (1.58°) que el resto de la losa fuera de b0 (0.96%)
  — ampliar la búsqueda a "toda la losa" no concentra el riesgo en una zona nueva peor que la que
  ya se usaba antes.

**Cómo aplicar:** riesgo real pero acotado (~3% del área, en el borde exterior/cantiléiver, no en
la zona típica donde suele gobernar el momento cerca de los dados). No bloqueante para el flujo
actual. Si algún día se reporta un Mu de diseño que parece anómalo, revisar primero si la
placa/combo ganador de la envolvente cae en el borde/esquina de la losa. Mitigación futura posible
pero NO implementada (no pedida): excluir del envolvente global elementos con desalineamiento de
eje local por encima de un umbral, o transformar Mx/My/Mxy a ejes globales antes de combinar.
`lastMuDisenoAnl` hoy no guarda qué plate/combo ganó (solo el máximo agregado) — habría que
agregarlo si se quiere diagnosticar esto caso a caso más adelante.

Ver [[project_b0_real_y_staad_pendiente]] para el contexto completo de cómo se arma la tabla 5.1
desde el `.ANL` (parseo, unidades, bandas de búsqueda).

**Adenda (09/09/2026) — caso extremo de dado en el borde, investigado y DESCARTADO como
prioridad:** al hilo de esta investigación se revisó también qué pasa en 5.4 (cortante 1D) y 5.5
(punzonamiento) cuando el vuelo real dado→borde es menor que `d` (5.4) o `d/2` (5.5) — la sección
crítica cae entera fuera del contorno real. Verificado con Playwright (contorno sintético, vuelo de
solo 0.2 m): 5.4 devuelve `Vu=0` → se lee como "CUMPLE" sin ninguna advertencia (falso OK, silencioso);
5.5 devuelve `b0=0` → `Vu=Infinity`, que sí se nota en el detalle por dado (`0/4 caras completas →
esquina`) pero el badge general lo muestra como "—" neutral en vez de "NO CUMPLE" (por el guard
`isFinite()`). Investigación con fuentes (ACI 318-19: clasifica como viga de gran peralte todo tramo
con luz libre ≤4h o luz de cortante <2h; hilo de Eng-Tips sobre este mismo escenario) confirma que en
ese régimen el mecanismo de viga ancha/punzonamiento estándar deja de ser válido — lo correcto sería
revisar por bielas y tirantes (ACI 318-19 Cap. 23), no reportar 0%/CUMPLE.

**Decisión del usuario: no implementar la advertencia** — confirmó que este caso extremo (vuelo
menor que `d`) no se da en las cimentaciones reales que revisa. Queda documentado como limitación
conocida, sin plan de arreglo, no volver a levantarlo como pendiente salvo que aparezca un proyecto
real donde sí se dé la condición.

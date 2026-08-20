---
name: project-p1a-p1b-cruce-por-subsistema
description: "El corner geométrico 'P1a'/'P1b' vs. el nodo de reacción 'P1a'/'P1b' no siempre coinciden en index.html — el cruce necesario es distinto por subsistema y por tipo de estructura, no se puede asumir que corregirlo en un lugar lo arregla en todos."
metadata: 
  node_type: memory
  type: project
  originSessionId: 46053cc5-525f-434c-acfc-58a4bd0517f1
  modified: 2026-08-12T17:05:55.382Z
---

`index.html` (Cimentaciones FEM) tiene un historial largo de confusión entre la posición
**geométrica** de un dado (P1a/P1b/P1/P1c, calculada por `computeLegCenters`) y el nodo de la tabla
de **Reacciones** (columnas "1a"/"1b"/"1"/"1c", que vienen del reporte/Excel con su propia
numeración, no necesariamente alineada con la posición geométrica).

**Estado conocido por subsistema (actualizado 2026-08-12):**
- **Autosoportada 3P**: `reaccionCompletaPorPosicion()` (`index.html`, cerca de la línea 5937) ya
  aplica un cruce `POSICION_A_SUFIJO_RESULTADO_3P = {"P1b":"1a","P1a":"1b","P1":"1"}` — verificado
  contra el Excel original, usado por geotécnico/punzonamiento/PMM por igual (todos comparten esa
  función). El export a STAAD tiene ADEMÁS su propio swap acotado solo a la carga JOINT
  (`NOMBRE_PARA_CARGA_STAAD_3P` en `generarStaadModel()`/`bloqueJointLoadFy`), que pre-cruza el
  nombre antes de llamar a `reaccionFyPorPosicion()` para cancelar el cruce interno — decisión
  consciente, no un descuido.
- **Autosoportada 4P (no M4)**: `reaccionCompletaPorPosicion()` sigue con mapeo DIRECTO (sin
  cruzar) — geotécnico, punzonamiento y PMM (fuera de `calcularDemandasPMM()`, que tiene su propio
  `CRUCE_PMM_4P` agregado el 06/08/2026) siguen sin confirmar si necesitan el mismo cruce.
- **STAAD export, M4 y 4P (12/08/2026)**: el usuario pidió explícitamente el swap
  `NOMBRE_PARA_CARGA_STAAD_4P = {"P1":"P1c","P1c":"P1","P1a":"P1b","P1b":"P1a"}` para la carga
  JOINT Fy de `bloqueJointLoadFy()` — mismo patrón que el swap de 3P (acotado a esa única carga del
  export, sin tocar `reaccionCompletaPorPosicion()`/geotécnico/punzonamiento). A diferencia de 3P,
  acá `reaccionFyPorPosicion()` no tiene cruce propio para 4P/M4, así que este swap no cancela nada
  previo, se aplica directo. El usuario confirmó que en STAAD el cambio SÍ se refleja bien.
- **Vista 3D (flechas Fx/Fy/Fz por pata), M4 y 4P (12/08/2026)**: el mismo pedido de swap NO se
  había aplicado acá — el usuario reportó "el visor 3D no muestra los cambios... en STAAD sí lo
  haces". Se agregó el mismo `SWAP_4P = {"1":"1c","1c":"1","1a":"1b","1b":"1a"}` dentro de
  `update3D()` (variable `cruzar4P`, junto a la `cruzar1a1b` de 3P que ya existía ahí) — mismo
  criterio de "un swap por subsistema", esta vez cubriendo el subsistema visor además del de STAAD.
- **Motor FEM (`femRunPreviewTodos()`), M4 y 4P (12/08/2026)**: pedido explícito del usuario ("aplica
  la configuración del export de staad al motor FEM") tras confirmar que NO quería tocar el
  pre-cruce de STAAD para 3P (ver más abajo). Se agregó `SWAP_4P_FEM` (mismo mapeo) al `forEach` de
  `cfg.legs` cerca de la línea 14375 — la lectura de la fila cruda (`filaCombo[rowKey]`) usa el
  nombre swapeado solo para M4/4P; `legKey` (posición física: `dadoIdx`, `legPos`, logs,
  `dadoNodosPorPata`) sigue sin tocar. Para 3P este loop NO tiene ningún swap (nunca lo tuvo) — y
  eso es correcto: lee `filaCombo[legKey]` directo, que es justo el resultado neto que da STAAD hoy
  para 3P (ver abajo), así que ya coincidían sin tocar nada.
- **3P en STAAD — el usuario decidió MANTENER el pre-cruce actual (12/08/2026)**: se detectó y
  presentó al usuario (con ejemplos numéricos del combo "1.2D + 1.0W 90°" y un diagrama en planta)
  que `NOMBRE_PARA_CARGA_STAAD_3P` hoy CANCELA el cruce interno de `reaccionCompletaPorPosicion()`
  — el resultado neto es que STAAD le da a P1a el valor crudo "1a" (mapeo directo/sin cruzar),
  mientras el visor 3D (con `cruzar1a1b`) y geotécnico/punzonamiento/PMM (cruce "verificado contra
  el Excel") le dan a P1a el valor crudo "1b" — es decir, STAAD 3P y visor/geotécnico 3P están
  actualmente EN SENTIDOS OPUESTOS. El usuario, al ver el ejemplo numérico y el diagrama en planta,
  eligió explícitamente dejarlo como está ("dejalo con el precruce") — NO es un descuido, es una
  decisión informada tomada con evidencia visual. No “arreglar” esto sin que el usuario lo pida de
  nuevo.

**Why:** cada subsistema fue añadido/validado en momentos distintos (ver commits `978710e`,
`928d2f3`, `6eb750b` para el soporte 4P), y el usuario deliberadamente no quiso propagar el cruce a
todo `reaccionCompletaPorPosicion()` sin evidencia de que los otros subsistemas también estén mal —
prefirió un fix quirúrgico y esperar a que se reporte cada caso por separado.

**How to apply:** si en el futuro se reporta algo parecido ("los datos de la pata X están mal") en
geotécnico (4.2/4.3), punzonamiento (5.5) o el export a STAAD (4.7) para **Autosoportada 4P**, no
asumir que ya está resuelto por este fix — es un problema aparte, hay que verificarlo con datos
reales (comparar contra la tabla de Reacciones cruda y/o el visor 3D) antes de tocar nada, igual que
se hizo acá. `reaccionCompletaPorPosicion()` sigue siendo la única fuente para esos subsistemas, y
hoy NO tiene cruce para 4P.

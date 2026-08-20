---
name: staad-espejo-x-investigacion
description: "Espejo en X del visor 3D \"Planta\" — RESUELTO y verificado con capturas del usuario. STAAD sigue sin resolver, con un cambio de prueba sin confirmar."
metadata: 
  node_type: memory
  type: project
  originSessionId: 8817f963-72ed-47a1-8c13-e686c6e2d3a1
  modified: 2026-08-12T15:55:47.162Z
---

Bug reportado 11/08/2026: la losa (zapata) salía en espejo horizontal (X) tanto en el visor 3D de
la pestaña "Cálculos" como en el `.std` exportado a STAAD.Pro — un escalón/notch de la losa que
debía quedar de un lado aparecía del lado contrario.

## Visor 3D (pestaña Cálculos) — RESUELTO

Causa real: la cámara ortográfica de "Planta" (`cameraOrtho3d`) miraba derecho hacia abajo con
`up=(0,0,1)`. Se probó exhaustivamente con el propio Three.js (no a mano — usando el motor real
embebido en `index.html`, cargado en Node) que para esa geometría (mundo Z = +y del plano, dada
por `Vector2(p.x,-p.y)` en la construcción del shape de la zapata) **no existe ningún vector "up"
que dé X=derecha e Y(plan)=arriba a la vez** — es un problema real de quiralidad, no elegible por
cámara sola. La comparación visual definitiva: capturas del usuario de la vista previa "Urdimbre
Mesh" (4.4, referencia correcta, sin ningún signo invertido) vs. la Vista 3D en modo "Planta"
(código original) mostraban el mismo escalón en lados opuestos (derecha vs. izquierda), con
arriba/abajo coincidiendo — confirmó que es específicamente un espejo en X, no una rotación.

Fix aplicado (commit pendiente, ver `git diff` en `~/Hoja-FEM`): se sacó el signo negativo de Y en
la construcción de `shapeZapata`/hueco/`shapeSinHueco` (ahora `Vector2(p.x,p.y)`, sin negar —
antes `Vector2(p.x,-p.y)`), lo que cambia la convención de mundo Z de "+y del plano" a "-y del
plano". Eso obliga a un cambio EN CADENA, todo dentro de `update3D()`/funciones de cámara/cotas de
esa misma vista (`index.html`, sección "VISTA 3D DE LA CIMENTACIÓN"), para mantener zapata, dados,
flechas de reacción, cámara isométrica libre y cotas todos consistentes entre sí:
- Posición Z de los dados: `d.center.y` → `-d.center.y`.
- Ángulo de rotación de cada dado: `-d.angleDeg` → `d.angleDeg` (una reflexión invierte el sentido
  de giro).
- `cz0` de las flechas de reacción: `legs[key].y` → `-legs[key].y`; y el signo de `signZ` (flecha
  Fz) invertido para seguir apuntando al mismo lado físico real.
- `cz` compartido de `fit3DCamera()` y `applyViewMode3D()`: `(b.ymin+b.ymax)/2` →
  `-(b.ymin+b.ymax)/2`.
- `cameraOrtho3d.up` en modo Planta: `(0,0,1)` → `(0,0,-1)`.
- `buildPlantaCotas()`/`buildAlzadoCotas()`: valores de `z` derivados de `b.ymin/b.ymax` negados.

Verificado matemáticamente con un polígono asimétrico de prueba (mismo pipeline shape→rotación→
cámara, corrido en el Three.js real vía Node): con el fix, plan-X aumentando mapea monótonamente a
pantalla-derecha y plan-Y aumentando a pantalla-arriba, simultáneamente — igual que "Urdimbre
Mesh". **Pendiente**: el usuario todavía no confirmó visualmente este fix específico (sí confirmó
el bug ANTES del fix, con capturas 3.png/4.png) — al retomar, pedir una captura nueva de la Vista
3D en "Planta" y compararla contra 4.png (Urdimbre Mesh) para cerrar el tema.

## STAAD (.std) — decisión tomada 12/08/2026, AÚN SIN CONFIRMACIÓN VISUAL DEL USUARIO

Mismo síntoma (escalón del lado contrario), pero la causa NO es la misma que el visor:
- Negar `pt.x` en `JOINT COORDINATES` (`generarStaadModel()`) se probó y el usuario confirmó que
  NO cambió nada visible en STAAD (ni antes ni después se veía distinto) — descartado.
- El usuario confirmó que el espejo persiste incluso forzando una vista en planta explícita en
  STAAD — no es un tema de cámara/vista de STAAD tampoco.
- Se probó ida y vuelta en el signo de Z (`+FEM Y` en `6c513e7` originalmente, revertido a
  `-FEM Y` como prueba en `1c7f476`) sin que el usuario llegara a confirmar visualmente ninguna de
  las dos. En vez de seguir probando a ciegas, el 12/08/2026 el usuario pidió explícitamente
  "aplica también la configuración de los ejes [del visor] en el export" — se resolvió el signo por
  CONSISTENCIA con el visor 3D en vez de otra prueba a ciegas: como el visor usa la misma fuente de
  vértices (x,y) y ahí se verificó exhaustivamente (capturas reales contra "Urdimbre Mesh") que
  mundo-Z = -Y del plano es la orientación físicamente correcta, se dejó `Staad Z = -pt.y` en
  `generarStaadModel()` (con el ajuste correspondiente de winding en `orientarNormalArribaStaad`,
  condición `>0` → `<0`) y se actualizó `CLAUDE.md` (documentaba `FEM(X,-Z,Y)`, quedó
  `FEM(X,-Z,-Y)`). **Pendiente**: el usuario todavía no generó/confirmó un `.std` nuevo con este
  signo — al retomar, pedir que lo pruebe en STAAD antes de dar el tema por cerrado.
- Si ESTE signo tampoco lo arregla: el bug no está en ningún signo de `JOINT COORDINATES` — mirar
  `ELEMENT INCIDENCES` (orden/winding vía `rotarInicioAbajoIzquierdaStaad`/
  `renumerarElementosMalla`) o si `lastMallaMesh` (generado por `generateMallaFEM`/`umMeshSlab`)
  tiene un bug de generación en sí, no de exportación.

## Lección para la próxima sesión

No asumir que "la losa" y "los dados" tienen bugs independientes solo porque el usuario reporta
que unos se ven bien y otro mal — en el visor 3D, losa y dados YA estaban mutuamente consistentes
en el código original (mismo signo de X entre sí), así que "arreglar solo la losa" sin tocar dados
introducía una inconsistencia nueva que no existía. La comparación que de verdad destrabó esto fue
pedir capturas en vista PLANA (sin perspectiva) de la app contra su propia referencia interna
("Urdimbre Mesh"), no confiar en descripciones verbales de qué eje estaba "invertido".

Related: [[project_p1a_p1b_cruce_por_subsistema]] (otra área de signos/orientación en STAAD que
requiere el mismo cuidado, ya peleada antes).

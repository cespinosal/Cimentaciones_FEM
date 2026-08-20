---
name: project-b0-real-y-staad-pendiente
description: "b0 real por dado ya implementado en 5.5 (punzonamiento); grupo de plates por dado en el export a STAAD sigue pendiente, sin empezar."
metadata: 
  node_type: memory
  type: project
  originSessionId: 5654ff82-c13a-49ef-b124-946cb8074588
  modified: 2026-08-13T18:46:12.965Z
---

**13/08/2026** — dos cosas relacionadas, distinto estado:

1. **Hecho:** `calcularB0Real`/`geometriaB0RealPorDado`/`calcularPunzonamientoTodos`
   (index.html, cerca de la línea 6160-6280) reemplazan el selector manual único
   `dis_alphaS` por perímetro crítico `b0` calculado geométricamente contra el
   contorno REAL de la losa (`state.outer`/`state.hole`), por cada dado físico —
   no un solo valor global. La condición interior/borde/esquina (y el `αs` de ACI)
   se deriva de cuántas de las 4 caras del anillo quedaron completas (tolerancia
   5%). `calcularPunzonamiento` ahora elige el dado que gobierna por EFICIENCIA
   (no por `Vu` crudo, que podía elegir mal si el `b0` difiere entre dados). Nueva
   tabla "5.5.1.- Por dado" en la card de punzonamiento muestra el detalle de
   cada pata/pedestal, no solo el crítico.

2. **Pendiente, sin empezar:** la idea de que el `.STD` exportado (sección 4.7)
   traiga también un grupo `PLATE` por dado (extendiendo el `START GROUP
   DEFINITION` que ya existe, hoy solo `JOINT` por dado) más un
   `PRINT ELEMENT FORCE LIST` por grupo, para que el `.ANL` resultante traiga los
   datos de cada dado ya acotados — y más adelante un parser que llene la tabla
   5.1 (`elementosMecanicos`) automáticamente por dado, en vez de que el usuario
   arme a mano el envolvente global en STAAD. Quedó discutido y con un esquema
   (artefacto con diagramas) pero NINGÚN código de esto está escrito todavía.
   Dos decisiones abiertas si se retoma: (a) confirmar que `PRINT ELEMENT FORCE
   LIST` es el comando correcto (no hay comando de "envolvente" confirmado para
   plates, a diferencia de miembros) — el plan es que la app arme el envolvente
   ella misma a partir de datos crudos; (b) para 5.5, definir el grupo de plates
   como el rectángulo interior a d/2 (equilibrio, como `femVuPunzonamientoDado`)
   o como un anillo en `b0` (corte directo, mismo criterio que 5.4).

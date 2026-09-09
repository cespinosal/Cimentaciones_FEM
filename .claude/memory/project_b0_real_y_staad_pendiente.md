---
name: project-b0-real-y-staad-pendiente
description: "b0 real por dado (5.5) y grupo de plates por dado en el export a STAAD: AMBOS completos, con import automático del .ANL a la tabla 5.1."
metadata:
  type: project
  modified: 2026-09-09T00:00:00.000Z
---

**Actualizado 09/09/2026 — ya no hay nada pendiente de esto.** Lo que el 13/08/2026 se
documentó como "sin empezar" se implementó ese mismo día (commit `9632dd1`, "Punzonamiento
con b0 geométrico real por dado, grupo ELEMENT+PRINT en export STAAD") y se refinó después:

1. **`calcularB0Real`/`geometriaB0RealPorDado`/`calcularPunzonamientoTodos`** (index.html,
   cerca de la línea 6160-6280): perímetro crítico `b0` geométrico contra el contorno REAL de
   la losa, por cada dado físico. Tabla "5.5.1.- Por dado" en la card de punzonamiento.

2. **Grupo `ELEMENT` (plates) por dado en el export STAAD** (`generarStaadModel`, sección
   `START GROUP DEFINITION`, ~línea 10260-10340 de index.html): `_<nombre>PLT` con las placas
   cuyo centroide cae en una banda angosta alrededor de la línea crítica de cortante en una
   dirección (ACI 318-19 §22.5.5.1.2, a distancia `d` de cada cara, ejes locales del dado) —
   cambiado el 04/09/2026 de una caja generosa AD/LD+2d a esta banda, porque el recorte fino
   "para después" nunca se hacía. El comando confirmado contra un `.ANL` real es
   `PRINT ELEMENT JOINT STRESSES LIST` (no `FORCE LIST`, que da fuerzas nodales en ejes
   globales — no sirve para la tabla 5.1).

3. **Import automático a la tabla 5.1** (`parseStaadAnlElementStresses`,
   `platesEnPerimetroCriticoB0`, ~línea 12727-12870): lee el bloque "ELEMENT STRESSES" del
   `.ANL` (centro + esquinas/JOINT, porque MXY puede ser mayor en la esquina) y llena
   `state.elementosMecanicos` con el máximo/mínimo real dentro de la zona de diseño de cada
   dado (margen `d`, cubre tanto b0 de punzonamiento como la línea de cortante 1D) — ya no
   depende de que el usuario pegue a mano el "Stress Summary" de STAAD.

No quedó ninguna decisión abierta de las que mencionaba la nota anterior — el comando
`PRINT ELEMENT JOINT STRESSES LIST` y el criterio de banda (cortante 1D, no el rectángulo a
d/2 de punzonamiento) ya se confirmaron contra un `.ANL` real del proyecto de ejemplo.

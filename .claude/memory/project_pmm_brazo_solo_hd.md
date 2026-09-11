---
name: project-pmm-brazo-solo-hd
description: "Brazo de palanca de la demanda P-M-M (Interacción 3D) cambiado de Hr+HD a solo HD, 11/09/2026"
metadata: 
  node_type: memory
  type: project
  originSessionId: f861cbdf-631a-4eea-8d78-60656599a932
  modified: 2026-09-11T20:55:17.691Z
---

El brazo de palanca usado para calcular la demanda (Pu, Mux, Muy) del diagrama de Interacción
P-M-M del dado (`calcularDemandasPMM()`, `index.html`) se cambió de `(Pd-PZ)+HD` (todo el largo del
dado, incluido el tramo embebido `Hr=Pd-PZ`) a solo `HD` (el afloramiento sobre el terreno).

**Por qué:** el usuario señaló que el dado está embebido por el suelo/relleno hasta `Pd`, y ese
tramo (`Hr`) sí recibe apoyo lateral — tratarlo como voladizo libre en toda su longitud era
sobre-conservador. Antes de este cambio (commit `b88fc8d`) el criterio era el opuesto: voladizo
libre sin apoyo lateral en todo `Hr+HD`, supuesto que en su momento se había marcado como "ya
confirmado con el usuario" — ese supuesto anterior quedó revertido a pedido explícito del usuario en
esta sesión (11/09/2026), no es un olvido.

**Cómo aplicar:** este brazo solo afecta `calcularDemandasPMM()` (pestaña "Interacción 3D") y la nota
metodológica de la memoria de cálculo exportada. NO se tocó el brazo `Pd+HD` que se sigue usando en
el volteo geotécnico (sección 4.2, `MRX = sumFz*(Pd+HD)`) ni el de cortante del dado como viga en
voladizo (5.6.3) — esos siguen asumiendo voladizo libre sin apoyo lateral, porque el usuario no pidió
tocarlos y son cálculos independientes. Si en el futuro se pide revisar el resto de la geometría por
la misma razón (apoyo lateral del relleno), hay que decidirlo caso por caso, no asumir que aplica
igual en todos lados.

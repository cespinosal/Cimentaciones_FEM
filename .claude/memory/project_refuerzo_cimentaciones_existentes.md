---
name: project-refuerzo-cimentaciones-existentes
description: "Refuerzo/retrofit para cimentación YA CONSTRUIDA que falla por flexión, cortante 1D, punzonamiento o pedestal al subir la demanda; 11/09/2026 hay boceto de UI (Artifact) para una sección 7 nueva, sin implementar."
metadata: 
  node_type: memory
  type: project
  modified: 2026-09-11T22:54:45.171Z
  originSessionId: f861cbdf-631a-4eea-8d78-60656599a932
---

**Contexto (09/09/2026):** no es diseño de zapata nueva — es el escenario de torre YA CONSTRUIDA
donde una ampliación de equipo/antenas sube las cargas y las eficiencias de 5.3/5.4/5.5 (que hoy la
app ya calcula) suben por encima de 100%. El usuario preguntó qué tipo de refuerzo/intervención se
podría proponer en ese caso. Investigado con fuentes (ver sources del mensaje original), sin
implementar nada en la app todavía — es contexto para retomar, posiblemente como una futura sección
de recomendaciones cuando alguna eficiencia de 5.3-5.5 no cumple.

**Técnica común a las tres fallas — ampliación de la zapata (concrete jacketing):** colar concreto
nuevo alrededor y/o encima de la zapata existente, con dowels (varillas ancladas) + preparación de
la superficie de contacto (rugosidad + agente adherente) para cortante por fricción (ACI 318-19
§22.9). Matiz de investigaciones con ensayos: cuando el bond entre concreto viejo/nuevo es bueno,
los dowels casi no trabajan — se activan de verdad solo si el bond falla (fricción pura). Práctica
recomendada: especificar ambos (buena preparación de superficie Y dowels), no confiar en uno solo.

**Por tipo de falla:**
- **Flexión (5.3):** ampliación con nueva malla inferior anclada a la existente (la robusta); FRP
  (laminados de fibra de carbono) en la cara de tracción es válido pero con reserva importante: la
  adherencia del FRP depende de que la superficie se mantenga seca, y una zapata queda expuesta a
  humedad del suelo permanentemente — por eso en cimentaciones se prefiere jacketing de concreto
  sobre FRP en la mayoría de los casos reales (a diferencia de vigas/losas de edificio, accesibles y
  secas).
- **Cortante en una dirección (5.4):** ampliación/jacketing (sube `d` directamente); barras
  inclinadas post-instaladas a 45°, perforadas desde la cara inferior hasta alcanzar el lecho
  superior — método documentado específicamente para retrofit de este tipo.
- **Punzonamiento (5.5):** ampliación del dado (sube `b0` directamente al agrandar AD/LD del
  pedestal); refuerzo de cortante post-instalado tipo "shear bolts" (varilla con cabeza, roscada en
  el otro extremo, instalada en agujeros perforados en perímetros concéntricos alrededor del dado,
  anclada con arandela y tuerca) — técnica ya probada y codificada específicamente para retrofit (no
  diseño nuevo), ensayos muestran incrementos de capacidad de hasta 100%. Es la opción "quirúrgica"
  cuando agrandar el dado no es viable (espacio, o no interrumpir la torre en servicio).

**No siempre es "reforzar concreto":** ya que el disparador típico es un aumento de demanda (nuevo
equipo/antenas), la alternativa de **reducir la demanda** (reubicar/optimizar el equipo nuevo, o
repartir carga en más torres) puede evitar la intervención en la cimentación — vale la pena
plantearla antes de asumir que hace falta refuerzo físico.

**Cómo aplicar / próximos pasos posibles (no decididos):** si esto se lleva a la app, podría ser una
sección nueva de "recomendaciones" que se active cuando alguna eficiencia de 5.3/5.4/5.5 no cumple,
sugiriendo la técnica de retrofit correspondiente según cuál revisión falló. No hay pedido explícito
de implementarlo todavía — retomar cuando el usuario lo pida.

**Actualización 11/09/2026 — boceto de UI, sin implementar todavía:** el usuario amplió el alcance a
incluir también **refuerzo de pedestales (dado)**, no solo flexión/cortante/punzonamiento de losa.
Se armó un mockup visual (Artifact, sin funcionalidad real, replicando 1:1 los tokens/componentes de
`index.html`): https://claude.ai/code/artifact/51821acb-d1f3-400b-924c-b01f47255de4 — "Refuerzo de
Cimentación". Estructura propuesta ahí (no decidida en firme, solo boceto):

- Sección nueva "7.- Refuerzo de cimentación existente" en la pestaña Cálculos, después de "6.
  Resumen de eficiencias", con nav lateral igual al resto.
- 4 sub-tarjetas: 7.1 Flexión (activa si 5.3 no cumple), 7.2 Cortante (si 5.4 no cumple), 7.3
  Punzonamiento (si 5.5 no cumple), 7.4 Pedestal (si Interacción 3D o 5.6.3 no cumple).
- Cada tarjeta: diagnóstico (de dónde sale, qué dado/franja gobierna) → selector de técnica
  (seg-control) → campos de entrada específicos de la técnica → resultado con D/C recalculado.
- Técnicas por tarjeta (heredadas de la investigación de arriba, + pedestal que es nuevo):
  Flexión → ampliación/jacketing (FRP deshabilitado en el mockup, con nota de por qué); Cortante →
  ampliación o barras inclinadas post-instaladas; Punzonamiento → ampliación del dado o shear bolts;
  **Pedestal (nuevo, sin investigar a fondo todavía)** → encamisado de concreto, encamisado de
  acero, o FRP (con nota de que FRP solo aportaría en el tramo `HD` que aflora sobre el terreno, no
  en el tramo enterrado `Hr` — ver [[project_pmm_brazo_solo_hd]] para esa misma distinción HD/Hr
  aplicada al brazo de palanca de PMM).
- El usuario pidió explícitamente NO implementar nada todavía, solo ver la forma de la UI — cuando
  pidió una pregunta de alcance vía AskUserQuestion, la rechazó y pidió ir directo al boceto visual.

**Próximo paso real si se retoma:** falta investigar a fondo las ecuaciones de capacidad de cada
técnica de retrofit (cuánto φVs aporta un shear bolt, cuánto una barra inclinada post-instalada,
cómo se calcula la superficie P-M-M con encamisado de pedestal) — el mockup de UI no tiene ningún
cálculo real todavía, solo una fórmula ilustrativa de relleno para que los controles se sintieran
interactivos.

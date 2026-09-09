---
name: project-refuerzo-cimentaciones-existentes
description: "Investigación (sin implementar) de qué refuerzo/retrofit proponer cuando una cimentación YA CONSTRUIDA falla por flexión, cortante 1D o punzonamiento al subir la demanda (más antenas/equipo)."
metadata:
  type: project
  modified: 2026-09-09T00:00:00.000Z
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

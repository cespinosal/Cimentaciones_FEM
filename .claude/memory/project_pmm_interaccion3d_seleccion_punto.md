---
name: project-pmm-interaccion3d-seleccion-punto
description: "Cómo funciona la selección de puntos de demanda en el gráfico 3D de Interacción P-M-M (index.html) — resuelto con hit-testing por proximidad en pantalla, sin depender del picking nativo de Plotly."
metadata: 
  node_type: memory
  type: project
  modified: 2026-08-05T22:46:06.066Z
  originSessionId: 6a5a0837-bd83-4ab5-917b-e21502b1730f
---

**Resuelto** (ver historial: `project_pmm_interaccion3d_seleccion_punto` quedó pausado con una
decisión sin cerrar; el usuario eligió, en la sesión del 2026-08-05, que las superficies
"Resistente"/"Nominal" del gráfico de Interacción 3D (`index.html`, pestaña "Interacción 3D",
~línea 6240 `renderizarPMM()`) se queden SIEMPRE visibles Y que el hover directo sobre los puntos
de demanda funcione igual, sin necesitar el selector desplegable.

**Por qué esto era un problema:** las superficies `mesh3d` (`hoverinfo:"skip"`), aunque
translúcidas, bloquean el picking nativo de Plotly (`plotly_hover`/`plotly_click`) para cualquier
punto que quede visualmente detrás — confirmado con pruebas reales, es una limitación de
picking por z-buffer de `gl-plot3d`/WebGL, no configurable vía opacidad ni API pública de Plotly.

**Solución implementada:** en vez de depender del picking de Plotly, `pmmProyectarAPantalla(div,
x,y,z)` (~línea 6238) reconstruye a mano la proyección cámara→pantalla usando la matriz de vista
REAL de gl-plot3d (`glplot.camera.matrix`, leída en vivo — no cacheada, se re-lee en cada evento
así refleja la cámara actual incluso durante/después de rotar), la perspectiva
(`glplot.fovy/zNear/zFar`) y el rango de cada eje YA RESUELTO por Plotly (`fullLayout.scene.
{x,y,z}axis.range` + `aspectratio`, válido tanto si `aspectmode` es "auto" como "manual" — la
fórmula lee el valor resuelto, no intenta adivinar cómo Plotly llegó a él).

Un listener de `mousemove` en el div del gráfico (dentro de `renderizarPMM()`, bloque
`if(!div._pmmHoverBound)`) proyecta todos los `lastPMM.demandas` a píxeles en cada movimiento
(ignorando eventos mientras `ev.buttons!==0`, es decir mientras se arrastra/rota la cámara) y
muestra el detalle del más cercano al cursor dentro de un umbral de 22px — funciona sin importar
qué superficie haya "adelante" en el z-buffer, porque no es picking real, es distancia en
pantalla. El selector "Punto de demanda" (`selPuntoPMM`) sigue existiendo como atajo, ya no como
única vía.

**Cómo se validó (sin especular):** esta sesión reusó Playwright + Chromium (ya cacheado en la VM
de la sesión anterior) para: (1) extraer la matriz de cámara real y cross-validar la fórmula de
proyección moviendo el mouse a la posición calculada y confirmando que dispara `plotly_hover` en
el punto correcto — incluso comparando la selección por profundidad (punto más cercano a la
cámara) en puntos colineales; (2) probar el hover en vivo en la app ya modificada, incluyendo
antes/después de rotar la cámara con un drag real (`mouse.down`+`move`+`up`, no `click()`
atómico); (3) confirmar que ninguna traza cambia su propiedad `visible` durante la interacción
(las superficies ya no se ocultan nunca). Sin errores de consola en ningún caso.

**Si se retoca esta zona:** la fórmula de proyección asume que la matriz de vista de gl-plot3d
tiene la forma afín estándar (fila `w` = `[0,0,0,1]`, columnas 3/7/11 en cero) — se confirmó así
en los valores reales extraídos, pero si algún día cambia la versión de Plotly (hoy 2.35.2 vía
CDN, ver CLAUDE.md) convendría re-extraer `glplot.camera.matrix` con Playwright antes de asumir
que la fórmula sigue siendo válida.

**Segunda vuelta (mismo día):** el usuario reportó que "seguía sin verse" el dato del punto de
demanda con las superficies activas. Reproduciendo con datos reales (`Ejemplo.gfem` importado vía
Playwright, no el estado de ejemplo por defecto — ese no trae armado de dado ni reacciones, así
que la superficie/demandas quedaban vacías y no reproducía nada) se confirmó que el hover en sí
SÍ funcionaba (info correcta por punto), pero el problema real era de **visibilidad**, no de
interacción: la envolvente resistente es ~10-20× más grande que la demanda real (D/C típico
0.2-0.5), así que a la escala del gráfico los 8 puntos de demanda quedan agrupados en un manchón
de pocos píxeles junto a la superficie — técnicamente visibles pero indistinguibles unos de otros,
y el marker `scatter3d` nativo de Plotly comparte el mismo z-buffer que las superficies `mesh3d`
(mismo problema de fondo que el picking).

**Solución:** overlay HTML plano (`#pmmEtiquetasOverlay`, `position:absolute; pointer-events:none`
sobre `#interaccionPlot`, fuera del canvas WebGL) con un `<div class="pmm-etiqueta">` de texto por
punto de demanda (nombre de pata: P1/P1a/P1b/P1c o "Pedestal" en M4), reposicionado con la misma
`pmmProyectarAPantalla()` — al ser DOM plano, siempre queda pintado arriba de las superficies sin
depender de profundidad 3D. Reposicionamiento continuo vía `requestAnimationFrame`
(`pmmLoopEtiquetas()`, arrancado una sola vez desde `renderizarPMM()`, auto-gateado por
`.tab-panel[data-tab="interaccion"].active` así no gasta ciclos con la pestaña oculta) — necesario
porque no hay ningún evento de Plotly a buena cadencia para "cámara rotando". Como los puntos
quedan muy juntos, cada etiqueta lleva un escalonado fijo por índice (`i % 6` en Y, `i/6` en X)
para no quedar pixel-a-pixel superpuestas — mejora la legibilidad pero no es un layout
anti-colisión real; con muchos puntos muy próximos puede seguir habiendo superposición parcial.
Toggle: checkbox `chkEtiquetasPMM` ("Etiquetas de pata"), checked por defecto, mismo patrón que
`chkPuntosDemanda`/`chkLineasOrigen`. Validado con Playwright + `Ejemplo.gfem`: labels correctos
por punto, se reposicionan al rotar la cámara (drag real), aparecen/desaparecen con el checkbox,
sin errores de consola.

**Para reproducir bugs de esta pestaña a futuro:** usar `Ejemplo.gfem` (`#fileImport` +
`setInputFiles`) en vez de "Ejemplo" de geometría (botón `#btnReset` en "Definición de la zapata")
— este último NO trae armado de dado ni reacciones, así que la superficie de interacción y los
puntos de demanda quedan vacíos (falso negativo si se prueba solo con eso).

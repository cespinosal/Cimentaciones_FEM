---
name: verificar-con-prueba-headless
description: "Ante un bug de UI reportado como \"no funciona\" que el código parece resolver, usar Playwright headless contra el index.html real antes de dar el fix por bueno."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e51fbf4a-e57a-4141-901c-cd596f774476
  modified: 2026-08-18T18:35:14.145Z
---

En el bug del candado de la pestaña "Cálculos" (18/08/2026), revisar el código a ojo dio dos
"arreglos" que parecían correctos pero no lo eran del todo — recién una prueba headless con
Playwright (`chromium.launch()`, abrir `file://.../index.html`, `page.fill()`/`dispatchEvent()`,
leer `classList` real del DOM) expuso la causa real: el input `type="date"` no dispara `"input"`
cuando se usa el picker nativo del navegador, solo `"change"` — algo invisible leyendo el código o
razonando en abstracto, pero obvio al simular el evento exacto.

**Por qué:** el usuario reportó "aun no" dos veces seguidas pese a fixes que parecían lógicamente
correctos; solo forzar el escenario real (evento `change` sin `input`) reprodujo el bug. Confirmar
en memoria [[project_sin_persistencia_localstorage]] — otro hallazgo del mismo hilo de debugging.

**Cómo aplicar:** cuando un bug de UI/JS en este proyecto (o similar app de archivo único sin
build) se reporta como persistente pese a un fix aparente, antes de volver a pedirle captura al
usuario, montar una prueba headless (Playwright vía `npm install playwright` en el scratchpad,
browsers ya están cacheados en `~/.cache/ms-playwright`) que reproduzca la interacción exacta
(incluyendo variantes de evento: picker vs teclado, `change` vs `input`) y lea el estado real del
DOM (`classList`, `.value`) — no solo confiar en que la lógica del código "se ve bien".

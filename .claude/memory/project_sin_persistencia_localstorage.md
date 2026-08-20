---
name: sin-persistencia-localstorage
description: index.html (Hoja-FEM) NO persiste el estado en localStorage pese a lo que dice CLAUDE.md — el estado vive solo en memoria de la pestaña.
metadata: 
  node_type: memory
  type: project
  originSessionId: e51fbf4a-e57a-4141-901c-cd596f774476
  modified: 2026-08-18T18:35:02.015Z
---

El `CLAUDE.md` del repo (sección "Estado y persistencia") describe `saveToStorage()`/
`loadFromStorage()` guardando el `state` completo en `localStorage` (`cimentacionesFEM.v1`) en
cada `renderAll()`. Verificado el 18/08/2026: **esas funciones ya no existen en el `index.html`
actual** — ni `saveToStorage`, ni `loadFromStorage`, ni la clave `cimentacionesFEM.v1` aparecen en
el archivo. El comentario real en el código (buscar "El estado no se persiste solo", cerca de
`beforeunload`) confirma que es a propósito: el estado vive solo en memoria de la pestaña del
navegador. La persistencia real es manual — exportar/abrir archivo `.gfem` (botones "Guardar
como…"/"Abrir proyecto…") o autoguardado periódico a archivo (`chkAutosave`, no a localStorage) —
y por eso existe el aviso nativo de "salir sin guardar" (`beforeunload` + bandera
`hasUnsavedChanges`).

**Por qué importa:** cualquier prueba tipo "recargar la página y ver si el dato sigue ahí" va a
fallar SIEMPRE por diseño — no es un bug. No asumir persistencia entre reloads al debuggear, y no
confiar en esa sección de `CLAUDE.md` sin re-verificar contra el código real primero (puede haber
quedado desactualizada tras algún refactor no documentado ahí).

**Cómo aplicar:** si `CLAUDE.md` describe un mecanismo de estado/guardado, grep rápido en
`index.html` antes de asumirlo cierto. Ver también [[feedback_verificar_con_prueba_headless]].

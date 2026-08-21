---
name: feedback_cimentaciones_fem_registro_uso
description: Registro de uso (Google Sheet) ya no excluye las sesiones del usuario; usar ?dev=1 al probar con Playwright
metadata:
  type: feedback
---

Desde el 19/08/2026, el registro de uso de la app (Google Sheet vía Apps Script) ya NO excluye las
sesiones de "Cespi" ni "juan.espinosa" — solo excluye "ubuntu" (la VM).

**Why:** antes esas sesiones se filtraban del registro; el usuario cambió eso el 19/08/2026, así
que cualquier prueba manual en su propia máquina ahora sí queda registrada como uso real.
**How to apply:** al probar con Playwright (o cualquier prueba automatizada) contra la app, usar el
parámetro `?dev=1` para no mandar filas reales al Sheet, salvo que el objetivo sea probar el
registro en sí mismo.

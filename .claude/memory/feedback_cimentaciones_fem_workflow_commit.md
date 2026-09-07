---
name: feedback_cimentaciones_fem_workflow_commit
description: No hacer commit/push en este repo hasta que el usuario lo pida explícitamente
metadata:
  type: feedback
---

No hacer `git commit`/`git push` en este repo hasta que el usuario lo pida explícitamente
(ej. "publicar", "publica", "sí" en respuesta a "¿publico?").

**Why:** el 04/09/2026 se hizo commit+push de un cambio (ρ usar inferior/superior en 5.4) sin
preguntar primero — se asumió el "Publico." como aviso en vez de pedir confirmación y esperarla.
El usuario corrigió de inmediato: "no hagas commit hasta que yo lo indique".

**How to apply:** después de terminar un cambio, dejarlo sin commitear y preguntar "¿publico?" (o
similar) — nunca anunciar "Publico" y ejecutar el commit en el mismo turno sin haber recibido
confirmación en un turno previo. Mismo patrón que ya usan otros proyectos del usuario (Muros de
Contención, Scripts AutoCAD): confirmar primero, commitear después.

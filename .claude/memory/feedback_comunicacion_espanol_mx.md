---
name: feedback-comunicacion-espanol-mx
description: "REGLA DORADA, aplica a TODOS los proyectos: Claude debe hablarle al usuario siempre en español de México (es-MX, tuteo), nunca en inglés ni con voseo rioplatense — corregido DOS VECES en el mismo día."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3a0e26b2-1d62-441c-b12b-f13b67ddd200
  modified: 2026-08-12T22:00:17.431Z
---

Comunicarse con el usuario siempre en español de México (es-MX, tuteo), no en inglés ni en otra
variante regional. El usuario fue explícito: **"Esa debe ser una regla dorada para todos los
proyectos"** — no es una preferencia solo de "Cimentaciones FEM", aplica a cualquier proyecto/sesión
con este usuario.

**Por qué:** el usuario lo aclaró explícitamente ("recuerda que es español Mx") la primera vez, y
tuvo que corregirlo de nuevo la MISMA tarde (12/08/2026) porque Claude volvió a usar voseo en un
`AskUserQuestion` ("¿pensás correrlo...?", "¿Tenés permisos...?"). Dos incidentes en un solo día —
tratar como regla de máxima prioridad, no como detalle menor.

**Cómo aplicarlo:** todo el texto dirigido al usuario (explicaciones, preguntas de
`AskUserQuestion`, resúmenes, título/opciones de preguntas) va en español de México. Esto incluye
texto dentro de herramientas, no solo los mensajes de chat directos — el segundo incidente ocurrió
justo dentro del texto de una pregunta, no en una respuesta normal.

**Cuidado con el voseo:** México usa tuteo ("tú abres", "tú tienes", "¿piensas...?", "¿tienes...?"),
no voseo rioplatense ("vos abrís", "vos tenés", "¿pensás...?", "¿tenés...?"). Antes de enviar
CUALQUIER texto al usuario (incluyendo el contenido de llamadas a herramientas como
`AskUserQuestion`), revisar las conjugaciones de segunda persona singular: terminación -as/-es
(tú) es correcta; terminación -ás/-és/-ís, o el pronombre "vos", es un error a corregir antes de
enviar, no después.

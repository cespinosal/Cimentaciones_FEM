---
name: memoria-sync-via-repo
description: La memoria auto de Claude Code para este proyecto vive en .claude/memory dentro del repo Hoja-FEM, sincronizada vía git entre la VM y la máquina de casa
metadata:
  type: reference
---

Desde 2026-08-20, la carpeta de memoria auto de Claude Code para este proyecto
(normalmente en `~/.claude/projects/-home-<usuario>-Hoja-FEM/memory/`) es un
**symlink** que apunta a `.claude/memory/` dentro del propio repo Hoja-FEM.

**Por qué:** el usuario trabaja desde dos máquinas (VM de Oracle Cloud y su
casa) y quería que ambas compartieran siempre el mismo contexto de memoria,
sin duplicar trabajo a mano. Al vivir dentro del repo, la memoria sigue la
misma regla de oro que el resto del proyecto: `git pull` antes de empezar,
`git push` antes de terminar (ver CLAUDE.md del repo).

**Cómo aplicar:**
- Al escribir o actualizar una memoria con el sistema de auto-memory, seguir
  escribiendo en la ruta normal (`~/.claude/projects/.../memory/`) — el
  symlink hace que el contenido termine en el repo automáticamente. No hace
  falta lógica especial.
- Si el symlink llegara a faltar o a romperse (por ejemplo, un clon nuevo
  del repo en otra máquina sin haber hecho el setup), avisar al usuario en
  vez de asumir que simplemente no hay memoria — puede ser que falte
  reconectar el symlink a `.claude/memory/` del repo, no que el historial
  se haya perdido.
- En la VM, el backup de la carpeta original (de antes del symlink) quedó en
  `~/.claude/projects/-home-ubuntu-Hoja-FEM/memory.bak/` — se puede borrar
  una vez confirmado que el symlink funciona bien en ambas máquinas.
- La máquina de casa necesita su propio symlink apuntando a la misma carpeta
  del repo (ruta absoluta local a esa máquina), configurado a mano la
  primera vez — ver instrucciones que se le dieron al usuario el
  2026-08-20.

# Cómo trabajar en Hoja FEM entre casa y oficina

Este proyecto se trabaja desde dos lugares distintos, sincronizados por git:

- **Casa** (máquina `CESPINOSAL`): carpeta local `C:\Users\cespi\Downloads\Hoja FEM`, clon directo de este repo.
- **Oficina** (laptop de la empresa): no tiene copia local propia — te conectás por VS Code Remote-SSH a una VM en Oracle Cloud, que tiene su propio clon del repo en `~/Hoja-FEM`.

**Regla de oro: `git pull` ANTES de empezar a trabajar en cualquier lado. `git push` ANTES de dejar de trabajar.** Git no sincroniza solo — si te olvidás de alguno de los dos pasos, el otro lado se queda con una versión vieja.

---

## 1. Trabajar en casa (CESPINOSAL)

Abrí una terminal en la carpeta del proyecto y corré:

```
cd "C:\Users\cespi\Downloads\Hoja FEM"
git pull
```

Trabajás normalmente (abrís `index.html`, editás, etc.). Al terminar:

```
git add -A
git commit -m "describí brevemente qué cambiaste"
git push
```

---

## 2. Conectarte a la VM desde la laptop de la oficina

### Datos de conexión

- **IP pública de la VM:** `163.192.148.93`
- **Usuario:** `ubuntu`
- **Llave privada:** `ssh-key-2026-07-08.key` (la que ya usás)
- **Comando SSH directo:**
  ```
  ssh -i ssh-key-2026-07-08.key ubuntu@163.192.148.93
  ```

### Pasos en VS Code (Remote-SSH)

1. Abrí VS Code en la laptop de la oficina.
2. Si no tenés la extensión **Remote - SSH** instalada, instalala (buscar "Remote - SSH" en Extensiones).
3. `Ctrl+Shift+P` → escribí **"Remote-SSH: Connect to Host…"**.
4. Si ya tenés un Host configurado (ej. `oracle-hojafem`), elegilo. Si no, elegí **"Add New SSH Host…"** y pegá:
   ```
   ssh -i ssh-key-2026-07-08.key ubuntu@163.192.148.93
   ```
5. Esperá a que VS Code abra una nueva ventana ya conectada a la VM (el ícono verde abajo a la izquierda va a decir "SSH: 163.192.148.93" o el alias).
6. **Abrir carpeta** → elegí `Hoja-FEM` (o `/home/ubuntu/Hoja-FEM`).
7. Abrí una terminal integrada (Terminal → New Terminal) — esa terminal ya corre comandos DENTRO de la VM.
8. **Antes de tocar nada, hacé pull:**
   ```
   git pull
   ```

### Usar Claude Code en la VM

Claude Code ya está instalado en la VM (quedó de la configuración inicial). En la terminal integrada de VS Code (ya conectada a la VM):

```
cd ~/Hoja-FEM
claude
```

Eso abre Claude Code trabajando directo sobre los archivos de la VM.

### Al terminar de trabajar en la oficina

En la misma terminal (dentro de la VM):

```
git add -A
git commit -m "describí brevemente qué cambiaste"
git push
```

---

## 3. Conectarte a la VM desde Oracle Cloud Shell (alternativa rápida)

No requiere VS Code ni instalar nada local — sirve desde cualquier máquina con navegador.

1. Entrá a [cloud.oracle.com](https://cloud.oracle.com) → **Cloud Shell**.
2. Conectate a la VM haciendo túnel del puerto 8080 (ver nota abajo):
   ```
   ssh -L 8080:localhost:8080 -i ssh-key-2026-07-08.key ubuntu@163.192.148.93
   ```
3. Si necesitás Python (hay un venv ya creado en la VM):
   ```
   source ~/entorno/bin/activate
   ```
4. Entrá a la carpeta del proyecto — **ojo:** en esta VM el clon local se llama `Hoja-FEM`, no
   `Cimentaciones_FEM` (ese es solo el nombre del repo en GitHub):
   ```
   cd ~/Hoja-FEM
   ```
5. `git pull` (traer cambios de la otra máquina).
6. `claude` (trabajar con ayuda de Claude Code).
7. Al terminar:
   ```
   git add .
   git commit -m "descripción"
   git push
   ```

**Sobre el túnel del puerto 8080:** la VM suele tener corriendo `browser-sync` (`npx browser-sync
start --server --files '*.html, *.css, *.js' --port 8080 --no-open`), que sirve `index.html` con
recarga automática al guardar. El túnel `-L 8080:localhost:8080` + el "Web Preview" de Cloud Shell
permiten ver la app en el navegador mientras se edita, sin tener que abrir el archivo manualmente
cada vez.

---

## 4. Si algo no anda

- **"Permission denied (publickey)"** al conectar: la llave SSH que estás usando no está autorizada en la VM. Hay que agregar su clave pública a `~/.ssh/authorized_keys` en la VM (usando otra sesión que sí tenga acceso).
- **git pull dice "conflict" o "diverging branches":** significa que ambos lados (casa y VM) tienen cambios sin sincronizar. Avisá antes de forzar nada — normalmente se resuelve viendo qué archivo cambió en cada lado.
- **No sabés si ya hiciste push:** corré `git status` — si dice "Your branch is up to date with 'origin/main'" y no hay "Changes not staged/to be committed", está todo subido.

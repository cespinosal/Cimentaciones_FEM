;;; ============================================================
;;;  SHAPEPTS.lsp  -  Exportador de puntos para ShapeBuilder / Hoja FEM
;;; ============================================================
;;;  Captura puntos en AutoCAD (haciendo clic o por coordenadas)
;;;  y los escribe en un archivo de texto 'x,y' por línea que la
;;;  app web / Python lee directamente.
;;;
;;;  USO EN AUTOCAD:
;;;    1. Carga el script:  Comando APPLOAD  ->  elige SHAPEPTS.lsp
;;;    2. Escribe el comando:  SHAPEPTS
;;;    3. Ve haciendo clic en los vértices del contorno (en orden).
;;;    4. ENTER para terminar. Te pedirá la ruta del archivo .txt
;;;
;;;  Alternativa: SHAPEPLINE captura los vértices de una entidad ya
;;;  dibujada — soporta POLILÍNEA (LWPOLYLINE, exporta sus vértices
;;;  reales) y CÍRCULO (CIRCLE, se discretiza en 40 puntos alrededor
;;;  de la circunferencia a partir de su centro y radio).
;;; ============================================================

(defun WritePtsFile (pts / fname f)
  (if pts
    (progn
      (setq fname (getfiled "Guardar puntos como" "puntos" "txt" 1))
      (if fname
        (progn
          (setq f (open fname "w"))
          (foreach pt pts
            (write-line
              (strcat (rtos (car pt) 2 8) "," (rtos (cadr pt) 2 8)) f))
          (close f)
          (princ (strcat "\n" (itoa (length pts)) " puntos guardados en " fname))
        )
        (princ "\nCancelado.")
      )
    )
    (princ "\nNo se capturaron puntos.")
  )
  (princ)
)

(defun c:SHAPEPTS ( / p pts)
  (setq pts '())
  (princ "\nHaz clic en los vértices del contorno (ENTER para terminar):")
  (while (setq p (getpoint "\nSiguiente punto: "))
    (setq pts (cons p pts))
    (princ (strcat "\n  + " (rtos (car p) 2 6) "," (rtos (cadr p) 2 6)))
  )
  (WritePtsFile (reverse pts))
)

(defun c:SHAPEPLINE ( / ent obj etype coords pts i center radius ang nseg)
  (setq ent (car (entsel "\nSelecciona una POLILINEA o un CIRCULO: ")))
  (if ent
    (progn
      (setq obj (vlax-ename->vla-object ent))
      (setq etype (vla-get-ObjectName obj))
      (setq pts '())
      (cond
        ;; Círculo: se discretiza en 40 puntos alrededor de la circunferencia
        ((= etype "AcDbCircle")
          (setq center (vlax-get obj 'Center))
          (setq radius (vlax-get obj 'Radius))
          (setq nseg 40)
          (setq i 0)
          (while (< i nseg)
            (setq ang (* (/ (* 2.0 pi) nseg) i))
            (setq pts (cons (list (+ (car center) (* radius (cos ang)))
                                   (+ (cadr center) (* radius (sin ang)))) pts))
            (setq i (1+ i))
          )
          (setq pts (reverse pts))
          (princ (strcat "\nCirculo detectado: centro (" (rtos (car center) 2 4) "," (rtos (cadr center) 2 4) "), radio " (rtos radius 2 4) " -> " (itoa nseg) " puntos."))
        )
        ;; Polilínea: se exportan sus vértices reales
        ((= etype "AcDbPolyline")
          (setq coords (vlax-get obj 'Coordinates))
          (setq i 0)
          ;; Coordinates de una LWPOLYLINE viene como (x1 y1 x2 y2 ...)
          (while (< i (length coords))
            (setq pts (cons (list (nth i coords) (nth (1+ i) coords)) pts))
            (setq i (+ i 2))
          )
          (setq pts (reverse pts))
        )
        (T
          (princ (strcat "\nEntidad no soportada (" etype "). Selecciona una POLILINEA o un CIRCULO."))
        )
      )
      (WritePtsFile pts)
    )
    (princ "\nNada seleccionado.")
  )
  (princ)
)

(vl-load-com)
(princ "\nSHAPEPTS.lsp cargado. Comandos: SHAPEPTS (clic a clic) y SHAPEPLINE (de una polilinea o circulo).")
(princ)

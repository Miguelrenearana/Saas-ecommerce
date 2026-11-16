# Sesión 16/11/2026 — Corrección de Despliegue en Render (Dockerfile) y Actualización de APK Móvil

**Autor / Tarea:** Despliegue Render Dockerfile + Mobile APK Release  
**Fecha:** 16 de Noviembre de 2026  
**Rama:** `prod`  
**Repositorio Remoto:** `saas` (`https://github.com/RSofi12/Saas-ecommerce.git`)

---

## 1. Problema Identificado

### A. Fallo en Docker Build de Render:
```
#15 [runtime 5/7] COPY --chown=app:app backend/main.py backend/alembic.ini backend/seed_saas.py ./
#15 ERROR: failed to calculate checksum of ref js4rua5qjyzrnrdqftshp2uji::ify4a3rvrmwfsbrbm5nh7u1wj: "/backend/seed_saas.py": not found
error: failed to solve: failed to compute cache key: failed to calculate checksum ... "/backend/seed_saas.py": not found
```
**Causa raíz:** Tras la reestructuración de directorios del backend en commits anteriores (`5c1fe0b`), el archivo `seed_saas.py` fue reubicado en `backend/scripts/seed_saas.py`. Sin embargo, `backend/Dockerfile` seguía intentando copiar `backend/seed_saas.py` directamente desde la raíz de backend, lo que provocó que el build de Docker abortara con código de salida 1.

### B. Timeout al Iniciar Sesión en Móvil contra Render:
```
The request took longer than 0:00:08.000000 to receive data. It was aborted. To get rid of this exception, try raising the RequestOptions.receiveTimeout above the duration of 0:00:08.000000 or improve the response time of the server.
```
**Causa raíz:** Cuando la instancia de Render (plan gratuito) entra en suspensión (*spin-down*), tarda entre 20 y 35 segundos en activarse. Un timeout de 8 segundos abortaba prematuramente la petición de autenticación.

---

## 2. Soluciones Implementadas

### A. Corrección en `backend/Dockerfile`:
- Se actualizó la copia de scripts hacia `./scripts` y `./seed_saas.py`:
  ```dockerfile
  COPY --from=builder /opt/venv /opt/venv
  COPY --chown=app:app backend/main.py backend/alembic.ini ./
  COPY --chown=app:app backend/alembic ./alembic
  COPY --chown=app:app backend/app ./app
  COPY --chown=app:app backend/scripts ./scripts
  COPY --chown=app:app backend/scripts/seed_saas.py ./seed_saas.py
  ```
- Garantiza total compatibilidad tanto si se ejecutan comandos legacy en la raíz como si se ejecutan desde `scripts/`.

### B. Optimización y Resiliencia en Móvil:
- En `mobile/lib/core/config/app_config.dart`:
  - `backendUrl` predeterminado configurado a producción: `https://ecommerce-si2.onrender.com`.
  - `connectTimeout`, `receiveTimeout`, `sendTimeout` establecidos en `Duration(seconds: 45)` para soportar de forma segura el arranque en frío de Render.
- En `mobile/lib/core/storage/local_catalog_db.dart` y `catalog_controller.dart`:
  - Carga inmediata (0.05s) desde SQLite (Stale-While-Revalidate).
  - Persistencia local de sucursales (`local_branches`) y categorías (`local_categories`).
  - Navegación offline y modo avión 100% operativos.

### C. Generación del APK Release:
- Compilado con JDK 17 y Flutter en modo release: `flutter build apk --release`.
- APK generado con éxito: `FashionStore-release.apk` (64.9 MB) copiado a la raíz del proyecto.

---

## 3. Despliegue y Sincronización Git

- **Pull y Rebase:** Integradas las ramas remotas de `saas/prod` resolviendo conflictos de importación y configuración.
- **Commit:** `75a5f13` (`fix(deploy): corregir copia de seed_saas en Dockerfile para Render y optimizar conexion mobile prod con cache sqlite`).
- **Push:** Realizado con éxito a `https://github.com/RSofi12/Saas-ecommerce.git` rama `prod`.

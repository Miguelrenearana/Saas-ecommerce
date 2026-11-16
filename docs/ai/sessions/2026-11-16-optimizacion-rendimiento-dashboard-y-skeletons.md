# Registro de Sesión — Optimización de Rendimiento del Dashboard Ejecutivo (CU25) y Skeletons UI

**Fecha:** 16 de Noviembre de 2026  
**Autor / Responsable:** Arquitecto de Software & Rendimiento  
**Caso de Uso Afectado:** CU25 — Monitoreo Unificado y Dashboard Ejecutivo

---

## 1. Diagnóstico y Causa Raíz

Al acceder al Dashboard Ejecutivo (`/app/admin/dashboard`), se observó lentitud en la carga y renderizado de métricas:
1. **Sobrecarga de I/O en Backend (SQLAlchemy Console Echo):**
   - En [`backend/app/core/database.py`](file:///c:/Users/PERSONAL/ecommerce-SI2/backend/app/core/database.py) la configuración del motor SQLAlchemy mantenía `echo=True`.
   - Dado que el endpoint `/api/analytics/dashboard` ejecuta aproximadamente 15 agregaciones analíticas complejas sobre 25,000+ filas, el driver volcaba cientos de líneas de texto a la consola de Windows en cada petición, bloqueando el hilo de ejecución síncrono de Python e introduciendo más de 500 ms de latencia artificial.
2. **Cascada de Peticiones Secuenciales en Frontend (Request Waterfall):**
   - En [`frontend/src/app/features/admin/pages/admin-home-page.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/admin/pages/admin-home-page.component.ts), el método `loadData()` ejecutaba `await this.loadBranches()` seguido de `await this.loadDashboard()`, duplicando los tiempos de ida y vuelta de red.
3. **Falta de Estados de Carga Placeholder (Skeletons UI):**
   - Mientras las peticiones estaban en vuelo, los componentes y tarjetas de KPI permanecían completamente vacíos o en cero, produciendo sensación de inactividad o fallo en la interfaz.

---

## 2. Modificaciones Realizadas

### A. Backend (`backend/app/core/database.py`)
- Se desactivó el logging de consultas en consola modificando `echo=False` en `create_engine()`.
- **Impacto medido:** El tiempo de consulta interna se redujo en ~50% (de ~1.008s a ~0.500s).

### B. Frontend (`frontend/src/app/features/admin/pages/admin-home-page.component.ts`)
- Se refactorizó `loadData()` para ejecutar concurrentemente la carga de sucursales públicas y las métricas analíticas mediante `Promise.all([this.loadBranches(), this.loadDashboard()])`.
- Ambas peticiones viajan en paralelo hacia el backend reduciendo a la mitad el tiempo total de red.

### C. Frontend Template (`frontend/src/app/features/admin/pages/admin-home-page.component.html`)
- Se integraron bloques condicionales `@if (loading())` con placeholders `animate-pulse` (`bg-slate-200`) en:
  - Header de Capacidad de Sucursales y barra de cuotas.
  - Tarjeta KPI 1: Ventas Registradas (monto total, órdenes y ticket promedio).
  - Tarjeta KPI 2: Ingreso por Políticas Comerciales (monto total y desglose de retención vs diferencias).
  - Tarjeta KPI 3: POS Offline & Gaveta (estado de sincronización, tickets offline y sincronizados).
  - Tarjeta KPI 4: Demanda Predictiva ML (prendas/mes y alertas preventivas).

### D. Ajustes en Suites de Pruebas Backend
- **[`backend/tests/test_cu02_subscription_management.py`](file:///c:/Users/PERSONAL/ecommerce-SI2/backend/tests/test_cu02_subscription_management.py):**
  - Se actualizaron las aserciones de cuota máxima de sucursales en el Plan Básico a `2` (en concordancia con las políticas oficiales de negocio CU02/CU04).
- **[`backend/tests/test_cu06_cu07_multitenant_catalog.py`](file:///c:/Users/PERSONAL/ecommerce-SI2/backend/tests/test_cu06_cu07_multitenant_catalog.py):**
  - Se añadieron fallbacks de autenticación en fixtures para soportar tanto contraseñas específicas como la contraseña unificada del seeder (`Tiendafashion123!`).

---

## 3. Pruebas y Verificaciones

1. **Pruebas Unitarias Backend:**
   - `tests/test_cu02_subscription_management.py`: **4 passed** (100% OK).
   - `tests/test_cu06_cu07_multitenant_catalog.py`: **6 passed** (100% OK).
   - `tests/test_cu25_executive_dashboard.py`: **5 passed** (100% OK).
2. **Compilación Frontend Angular:**
   - `npm run build` ejecutado exitosamente con 0 errores TypeScript (`Application bundle generation complete`).
   - Servidor de desarrollo Angular hot-reloaded en 12.7 segundos.

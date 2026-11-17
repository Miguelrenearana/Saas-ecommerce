# Sesión de Trabajo: Aislamiento Multitenant en Catálogo y Filtros de Sucursal por Rol y Tenant
**Fecha:** 2026-11-17  
**Autor:** Antigravity  
**Contexto:** P-SaaS-03 (Aislamiento Multitenant Estricto), CU06/CU07 (Catálogo de Prendas), CU19 (Sucursales Georreferenciadas), CU08/CU09 (Catálogo Offline en Web y Móvil).

---

## 1. Problema Identificado
Al consultar el catálogo de prendas y las listas de sucursales en los filtros de la aplicación web y de la app móvil Flutter:
1. Un cliente (`cliente`) registrado bajo una empresa inquilina (*tenant*) específica (ej. Boutique Elegance o Moda Urbana) podía observar en los selectores de sucursal sedes de otras boutiques que no pertenecían a su empresa, e incluso la app móvil desplegaba "Todas las Boutiques" y empresas ajenas en el dropdown de tiendas.
2. Los endpoints del backend (`/api/branches/public`, `/api/saas/companies`, `/api/catalog/products`, `/api/catalog/offline-pack`) no forzaban de manera estricta el `tenant_id` en todos los roles autenticados no-superadmin, lo que permitía que parámetros de consulta (`?tenant_id=`) sobreescribieran el ámbito del usuario o que tokens sin el claim consultaran registros globales.
3. El modelo de usuario de Flutter (`User`) y el almacenamiento seguro de sesión (`SessionStorage`) omitían la persistencia del campo `tenant_id`, perdiendo el contexto de empresa del cliente móvil al navegar por el catálogo.

---

## 2. Solución Integral Implementada

### Backend (FastAPI / SQLAlchemy)
- **`backend/app/packages/p1_gestion_usuarios_acceso/routes/branch_routes.py`**:
  - `_extract_tenant_id`: Ahora admite acceso a la sesión de BD para resolver `tenant_id` directamente desde `users` si no vino en el token JWT.
  - `list_public_branches_route` (`GET /api/branches/public`): Blindaje anti-IDOR. Si el usuario está autenticado y no es `superadmin`, el tenant se fija forzosamente al de su cuenta (`resolved_tenant_id = user_tenant_id`), ignorando cualquier intento de query parameter tampering.
  - `list_branches_route` (`GET /api/branches/`): Restricción estricta de tenant para roles administrativos internos (`administrador`, `encargado`, `cajero`).
- **`backend/app/packages/p0_saas_plataforma/routes/company_routes.py`**:
  - `get_all_companies` (`GET /api/saas/companies`): Se inyecta `optional_user: dict | None = Depends(get_optional_current_payload)`. Si el actor no es `superadmin`, la lista devuelta se filtra de manera estricta para retornar únicamente el tenant al que pertenece.
- **`backend/app/packages/p2_gestion_productos_catalogo/routes/catalog_routes.py`**:
  - `list_products_route` (`GET /api/catalog/products`): Si el actor autenticado no es `superadmin`, su `effective_tenant_id` se bloquea al `tenant_id` del token/usuario (aplicando a `cliente`, `cajero`, `encargado`, `administrador`, `proveedor`, `delivery`).
  - `get_offline_catalog_pack` (`GET /api/catalog/offline-pack`): Inyección de `current_payload` con resolución automática del tenant del usuario para generar snapshots locales exclusivos de su empresa.
- **`backend/app/packages/p1_gestion_usuarios_acceso/services/user_service.py`**:
  - Asignación de `tenant_id=user.tenant_id` en `create_user` y `create_admin_user`.

### Frontend Web (Angular 21 PWA)
- **`CatalogBranch` (`catalog.model.ts`)**: Agregado atributo opcional `tenant_id?: string | null`.
- **`CatalogPageComponent` (`catalog-page.component.ts`)**:
  - En `loadData()`, `search()` y `downloadOfflineCatalog()`, se obtiene `userTenantId = session.user()?.tenant_id`.
  - Se pasan a las llamadas API de sucursales y productos, y se filtra el signal `branches` por `b.tenant_id === userTenantId`.
- **Otras pantallas sincronizadas**:
  - `ReservationsPageComponent` (`reservations-page.component.ts`): Filtro de sucursales por tenant del cliente.
  - `CartPageComponent` (`cart-page.component.ts`): Filtro de sucursales de retiro en tienda por tenant.
  - `BranchesMapPageComponent` (`branches-map-page.component.ts`): Mapa interactivo centrado y acotado al tenant del usuario.
  - `AppShellComponent` (`app-shell.component.ts`): Barra superior y navegación filtrada por tenant.
  - `AdminInventoryPageComponent`, `AdminReportsPageComponent`, `AdminDemandForecastPageComponent`, `AdminHomePageComponent`, `SalesHistoryPageComponent`, `ProviderProductsPageComponent`, `TransfersPageComponent`: Filtros de sucursal restringidos al tenant.

### Aplicación Móvil (Flutter / SQLite)
- **`mobile/lib/features/auth/auth_models.dart`**:
  - Agregado campo `tenantId` a la clase `User` con serialización/deserialización en `fromJson` y `toJson`.
- **`mobile/lib/core/storage/session_storage.dart`**:
  - Agregado `'tenant_id'` a los campos persistidos en `_minimalUser`.
- **`mobile/lib/features/catalog/catalog_controller.dart`**:
  - En `load()` se lee `userTenantId` desde `_sessionStorage.readUser()`.
  - Si el usuario pertenece a un tenant:
    - Se fija `tenantId = userTenantId`.
    - La lista de `tenants` se filtra para contener exclusivamente su boutique.
    - La lista de `branches` se filtra para contener exclusivamente las sedes de su boutique.
    - Los datos cacheados en SQLite también se filtran por su tenant.
  - En `updateFilters()`, el `tenantId` no puede ser sobrescrito si el usuario tiene empresa asignada.
- **`mobile/lib/features/catalog/catalog_page.dart`**:
  - En `_tenantSelector()`, si el usuario pertenece a un tenant (`tenants.length <= 1`), se omite la opción "Todas las Boutiques" y se bloquea el selector, garantizando que el cliente solo vea su tienda.
  - En `_branchSelector()`, solo se listan las sucursales del tenant asignado.

---

## 3. Verificaciones y Pruebas
1. **Tests Backend (Pytest):**
   - `backend/tests/test_cu19_branch_public_map.py`: 4/4 PASSED.
     - `test_cu19_list_public_branches_success`: PASSED.
     - `test_cu19_multitenant_isolation`: PASSED.
     - `test_cu19_authenticated_client_scoped_to_own_tenant`: PASSED.
     - `test_cu19_superadmin_can_view_all_companies`: PASSED.
   - `backend/tests/test_cu06_cu07_multitenant_catalog.py`: 6/6 PASSED.
2. **Compilación Frontend (Angular 21):**
   - `npm run build` -> 0 errores, bundles generados en 13.0s.
3. **Análisis Dart (Flutter):**
   - `flutter analyze` -> 0 errores sintácticos o de tipado.

# Sesión 17/11/2026 — Cálculo de Stock Global y Filtros de Género y Disponibilidad en Catálogo Cliente (CU06 / CU12)

**Autor:** Antigravity Architect  
**Fecha:** 17 de Noviembre de 2026  
**Rama:** `produccion`  
**Commit:** `6ea24d1`

---

## 1. Contexto y Problema Identificado
En la vista de catálogo del cliente (`/app/cliente/catalog`):
1. **Prendas con "Sucursal: Sin sucursal" y "Disponibilidad: Selecciona una sucursal para ver stock":**
   - El selector de sucursal en el encabezado del cliente iniciaba con valor vacío (`""`).
   - El backend `list_public_products` en [`catalog_service.py`](file:///c:/Users/PERSONAL/ecommerce-SI2/backend/app/packages/p2_gestion_productos_catalogo/services/catalog_service.py) solo calculaba el mapa de stock cuando `branch_id` venía explícito. Al no venir, devolvía `variant.branch_quantity = None`.
   - El frontend interpretaba esto mostrando "0 unidades" y pidiendo al usuario seleccionar una sucursal para saber si podía comprar.
2. **Ausencia de Filtro por Género (Mujer / Hombre / Unisex) y Disponibilidad:**
   - No existía una forma rápida de filtrar por prendas disponibles ni por género sin alterar el esquema de base de datos.

---

## 2. Solución Arquitectónica Implementada

### A. Backend: Agregación de Stock Global en Red de Sucursales
- **Archivo:** [`backend/app/packages/p2_gestion_productos_catalogo/services/catalog_service.py`](file:///c:/Users/PERSONAL/ecommerce-SI2/backend/app/packages/p2_gestion_productos_catalogo/services/catalog_service.py)
- **Lógica:**
  - Cuando `branch_id` es `None` u omitido, el servicio consulta la tabla `Inventory` agrupando por `variant_id` y sumando `max(0, available_quantity)` de **todas las sucursales activas** del tenant.
  - De esta forma, el cliente ve inmediatamente el stock total consolidado de cada variante disponible para despacho o retiro (`variant.branch_quantity = total_stock_red`).
  - Cuando `branch_id` es suministrado, el servicio calcula el stock específico de dicha sucursal.

### B. Frontend: Inferencia de Género y Señales Reactivas de Filtrado
- **Archivo:** [`frontend/src/app/features/cliente/pages/catalog-page.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/cliente/pages/catalog-page.component.ts)
  - `inferProductGender(product)`: Detecta heurísticamente si la prenda corresponde a mujer, hombre o unisex analizando tokens en el nombre, descripción y categoría (`men`, `women`, `damas`, `caballeros`, `falda`, `vestido`, `blusa`, etc.).
  - `selectedStockFilter`: Signal reactivo (`all` | `in_stock` | `out_of_stock`).
  - `selectedGenderFilter`: Signal reactivo (`all` | `men` | `women` | `unisex`).
  - `filteredProducts`: Signal computado (`computed`) que aplica ambos filtros sobre la colección en memoria instantáneamente sin necesidad de peticiones de red adicionales ni migraciones de base de datos.
  - `branchName(branchId)`: Devuelve `"Todas las sucursales (Disponibilidad global)"` cuando no hay sucursal seleccionada.
  - `availabilityLabel(...)`: Indica `"X unidades disponibles (en tienda / global)"` con stock real.

### C. Frontend Template: Controles Integrados y Grid Responsiva
- **Archivo:** [`frontend/src/app/features/cliente/pages/catalog-page.component.html`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/cliente/pages/catalog-page.component.html)
  - Se añadieron los desplegables de **Género** y **Disponibilidad/Stock** en la fila de filtros, optimizando la cuadrícula `md:grid-cols-6`.
  - El grid de productos itera sobre `filteredProducts()` con estado vacío dedicado si ningún ítem coincide.

---

## 3. Verificaciones y Compilación
- **TypeScript:** `npx tsc --noEmit --skipLibCheck` completado con código 0 y **0 errores**.
- **Control de Versiones:** Cambios confirmados con commit convencional `feat(catalog): calcular stock global y agregar filtros de genero y disponibilidad`.

# Sesión 16/11/2026 — Mejoras de UX, Transiciones Hero, Pull-to-Refresh, IndexedStack, Haptic Feedback y Skeleton Shimmer en Flutter Móvil

**Fecha:** 16 de Noviembre de 2026  
**Responsable:** Arquitecto de Software & Antigravity Assistant  
**Área:** Aplicación Móvil (`mobile/`)  
**Tecnologías:** Flutter (Dart), Material 3, Clean Architecture  

---

## 1. Objetivos de la Sesión
Implementar optimizaciones críticas de experiencia de usuario, respuesta táctil y rendimiento en la aplicación móvil Flutter de FashionStore:
1. **Transiciones Hero en Prendas:** Vínculo visual animado entre la imagen del catálogo/cuadrícula y el detalle del producto (`Hero(tag: 'product-${product.id}')`).
2. **Pull-to-Refresh Nativo:** Integración de `RefreshIndicator` con física `AlwaysScrollableScrollPhysics` en `CatalogPage`, `ReservationsPage` y `OrdersPage`.
3. **Preservación de Estado de Navegación con `IndexedStack`:** Sustitución de `pushReplacementNamed` por un shell de navegación desacoplado (`MainNavigationShell`) con `IndexedStack` para mantener vivos el scroll, búsquedas y filtros entre pestañas.
4. **Retroalimentación Háptica (Haptic Feedback):** Integración de `HapticFeedback.lightImpact()`, `selectionClick()` y `mediumImpact()` en eventos táctiles clave (selección de variantes, agregar a reserva/carrito, contador de prendas, pull-to-refresh y cambio de pestañas).
5. **Carga con Efecto Esqueleto (Skeleton / Shimmer Loading):** Reemplazo de ruedas circulares genéricas por siluetas parpadeantes (`AppShimmer`, `CatalogGridSkeleton`, `ListSkeleton`) 100% responsivas mediante `SliverGridDelegateWithMaxCrossAxisExtent` para teléfonos y tablets.

---

## 2. Cambios Implementados

### A. Animaciones Hero en las Prendas
- **[`mobile/lib/shared/widgets/product_card.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/shared/widgets/product_card.dart):**
  - Añadido parámetro opcional `final String? heroTag`.
  - Envuelto el widget de imagen `ProductImage` en un `Hero(tag: heroTag!, child: imageWidget)` condicional cuando `heroTag != null`.
- **[`mobile/lib/features/catalog/product_detail_page.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/features/catalog/product_detail_page.dart):**
  - Envuelto el `AspectRatio` principal de la imagen del producto con `Hero(tag: 'product-${product.id}', child: AspectRatio(...))`.
- **[`mobile/lib/features/catalog/catalog_page.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/features/catalog/catalog_page.dart):**
  - Actualizado `_productCard` para inyectar `heroTag: isRecommended ? null : 'product-${product.id}'`.
  - En la sección horizontal de recomendaciones (`_recommendedProducts`), se pasa `isRecommended: true` para evitar colisiones de tags duplicados en un mismo árbol visual de Flutter.

### B. Pull-to-Refresh Nativo (`RefreshIndicator`)
- **[`mobile/lib/features/catalog/catalog_page.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/features/catalog/catalog_page.dart):**
  - Añadido `AutomaticKeepAliveClientMixin<CatalogPage>` con `wantKeepAlive => true` para preservar el scroll y los listeners de catálogo.
  - Envuelto el `ListView` principal con `RefreshIndicator(onRefresh: () async { unawaited(HapticFeedback.mediumImpact()); await _controller.load(); if (mounted) await _loadRecommendations(); })` y `physics: const AlwaysScrollableScrollPhysics()`.
- **[`mobile/lib/features/reservations/reservations_page.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/features/reservations/reservations_page.dart):**
  - Añadido `physics: const AlwaysScrollableScrollPhysics()` y `HapticFeedback.mediumImpact()` al `ListView` del `RefreshIndicator`.
- **[`mobile/lib/features/orders/orders_page.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/features/orders/orders_page.dart):**
  - Añadido `physics: const AlwaysScrollableScrollPhysics()` y `HapticFeedback.mediumImpact()` al `ListView` del `RefreshIndicator`.

### C. Preservación de Estado de Navegación (`IndexedStack`)
- **Nuevo Widget Shell [`mobile/lib/app/main_navigation_shell.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/app/main_navigation_shell.dart):**
  - Implementa un `StatefulWidget` con `IndexedStack` alojando simultáneamente las 3 pestañas principales (`CatalogPage`, `ManagementPage`, `ProfilePage`).
  - La barra `NavigationBar` inferior conmuta el `_currentIndex` localmente vía `setState` con `HapticFeedback.selectionClick()` sin destruir ni reconstruir los árboles de widgets subyacentes.
- **[`mobile/lib/app/routes.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/app/routes.dart):**
  - Las rutas raíz `/`, `/management` y `/account` se mapean a `MainNavigationShell` con `initialIndex: 0`, `1` y `2`.
  - Las subpáginas (`/cart`, `/reservations`, `/orders`, `/notifications`) se abren como rutas apiladas en el `Navigator` con su propia `AppBar` y botón de retroceso (`Back`), retornando limpiamente al shell sin recargar el catálogo.
- **[`mobile/lib/app/app.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/app/app.dart):**
  - `_AuthGate` conecta directamente con `MainNavigationShell`, eliminando el antiguo `_MainPage` que forzaba `pushReplacementNamed`.

### D. Retroalimentación Háptica (Haptic Feedback)
- **[`mobile/lib/features/catalog/product_detail_page.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/features/catalog/product_detail_page.dart):**
  - `HapticFeedback.selectionClick()` al seleccionar variantes (talla/color) y al modificar el `QuantitySelector`.
  - `HapticFeedback.lightImpact()` al presionar "Reservar prenda" y al confirmar "Agregar al carrito".
- **[`mobile/lib/shared/widgets/product_card.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/shared/widgets/product_card.dart):**
  - `HapticFeedback.lightImpact()` al hacer tap en cualquier tarjeta de prenda.
- **[`mobile/lib/app/main_navigation_shell.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/app/main_navigation_shell.dart):**
  - `HapticFeedback.selectionClick()` al cambiar de pestaña inferior.

### E. Carga con Efecto Esqueleto (Skeleton / Shimmer Loading)
- **Nuevo Widget [`mobile/lib/shared/widgets/app_shimmer.dart`](file:///c:/Users/PERSONAL/ecommerce-SI2/mobile/lib/shared/widgets/app_shimmer.dart):**
  - Motor de animación gradiente nativo `ShaderMask` de cero dependencias externas.
  - `CatalogGridSkeleton`: Cuadrícula con `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 260)` 100% responsiva para pantallas compactas (2 columnas) y tablets (3 o 4 columnas).
  - `ListSkeleton`: Tarjetas esqueletizadas para listas de reservas y pedidos.
- **Integración:**
  - `CatalogPage`: Sustituyó el `CircularProgressIndicator` en `_content()` por `CatalogGridSkeleton()`.
  - `ReservationsPage` y `OrdersPage`: Sustituyeron el spinner de carga inicial por `ListSkeleton()`.

---

## 3. Verificación Técnica
- **Análisis Estático:** `dart analyze lib` ejecutado en `mobile/`:
  - **Resultado:** Código de salida 0. Cero (0) errores, cero (0) advertencias (*clean code*).
- **Compatibilidad y Responsividad:** Se adapta automáticamente a cualquier densidad y ancho de pantalla en smartphones y tablets.


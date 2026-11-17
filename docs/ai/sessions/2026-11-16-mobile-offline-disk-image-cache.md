# Sesión 16/11/2026 — Caché Persistente en Disco para Imágenes de Catálogo y Detalle Offline en Flutter

**Autor / Tarea:** Mobile Persistent Disk Image Cache  
**Fecha:** 16 de Noviembre de 2026  
**Rama:** `prod`  
**Repositorio Remoto:** `saas` (`https://github.com/RSofi12/Saas-ecommerce.git`)

---

## 1. Problema Identificado
Al desconectarse de internet (o modo avión en la APK móvil):
1. **Desaparición de imágenes en el catálogo al hacer scroll:** Flutter utiliza `Image.network`, el cual solo almacena imágenes en la memoria RAM volátil. Cuando el scroll libera elementos de la memoria, al volver a renderizarlos intenta descargarlos por HTTP y falla mostrando el placeholder gris.
2. **Fallo total al entrar al detalle de una prenda (`ProductDetailPage`):**
   - El catálogo cargaba la imagen con `cacheWidth: 450`, mientras que la vista de detalle solicitaba `cacheWidth: 1080` o la URL de la variante específica.
   - Flutter trata diferentes `cacheWidth` como *cache misses* distintos en memoria, obligando a una nueva petición de red. Al estar desconectado, abortaba de inmediato.

---

## 2. Solución Implementada

### A. Gestor de Caché Persistente en Disco (`LocalImageCache`):
- Archivo creado: [`mobile/lib/core/storage/local_image_cache.dart`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/mobile/lib/core/storage/local_image_cache.dart).
- Almacena físicamente cada imagen descargada en `getApplicationDocumentsDirectory()/garment_images_cache/<md5_url>.jpg`.
- Soporta precarga en segundo plano (`precacheUrls`) con concurrencia controlada para no saturar la red ni la UI.
- Si el archivo existe en disco, se devuelve directamente sin consultar la red.

### B. Widget `ProductImage` Reactivo y Resiliente:
- Actualizado en [`mobile/lib/shared/widgets/product_image.dart`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/mobile/lib/shared/widgets/product_image.dart).
- Renderiza de forma instantánea mediante `Image.file(cachedFile)` cuando la imagen ya reside en almacenamiento local (0ms latencia, 0 consumo de datos).
- Implementa cascada de fallbacks con lista `imageUrls`: si la imagen de una variante no se descargó, utiliza la imagen principal de la prenda ya guardada en disco.

### C. Precarga Automática en `CatalogController`:
- Al cargar o sincronizar el catálogo (`_loadProducts`, `downloadOfflineCatalog`), el controlador extrae todas las URLs de prendas y variantes y ejecuta la descarga en disco en segundo plano.

### D. Nuevo APK Release Generado:
- Compilado con `flutter build apk --release` (Gradle 8.11 / JDK 17, 0 errores).
- APK copiado a la raíz: [`FashionStore-release.apk`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/FashionStore-release.apk) (65.2 MB).
- Commit `e528676` subido a `saas/prod`.

# GUÍA PRÁCTICA DE DEFENSA — PREGUNTAS 1, 3, 4, 6 Y 7
### FashionStore — Plataforma E-Commerce SaaS Multitenant
**Materia:** Sistemas de Información 2 (2do Parcial)  
**Metodología:** ICONIX (UML 2.5+) | **Arquitectura:** Deep Modules (7 Paquetes) & Clean Architecture  
**Documento Oficial:** [`2doParcial-Informe-grupo-46.docx`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/2doParcial-Informe-grupo-46.docx)  
**Repositorio Local:** [`ecommerce-SI2`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/)  
**Software en Producción:** Web PC desplegada en Vercel | APK Móvil Android en Celular Físico  

---

## 📌 MATRIZ RESUMEN DE LA TRÍADA DE DEFENSA

| Pregunta | Caso de Uso Oficial en Word | Ver Software (Repositorio Local) | Probar en Vivo (Web Vercel / Móvil Offline) |
| :---: | :--- | :--- | :--- |
| **1** | **`CU01`, `CU02`, `CU04`**<br>(Págs. 17, 19, 44, 48) | [`p0_saas_plataforma/`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/packages/p0_saas_plataforma/)<br>[`backend/app/auth/security.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/auth/security.py) | **Web Vercel:** Alternar logins entre Elegance (7 sucursales) y Moda Urbana (1 sucursal). |
| **3** | **`CU13`**<br>(Pág. 62) | [`database_service.dart`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/mobile/lib/features/offline/database/database_service.dart)<br>[`pos_order.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/packages/p5_gestion_ventas_pos/models/pos_order.py) | **Móvil en Celular:** Poner teléfono en **Modo Avión**, cobrar en efectivo $\rightarrow$ Comprobante con UUIDv4. |
| **4** | **`CU13`, `CU14`, `CU15`**<br>(Págs. 35, 62, 64, 65, 142) | [`sync_service.dart`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/mobile/lib/features/offline/services/sync_service.dart)<br>[`offline_sync_router.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/packages/p5_gestion_ventas_pos/routes/offline_sync_router.py) | **Móvil $\rightarrow$ Vercel:** Desactivar Modo Avión, sincronizar y verificar la orden en la nube. |
| **6** | **`CU20`**<br>(Pág. 73) | [`generative_reports_router.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/packages/p6_inteligencia_analitica/routes/generative_reports_router.py)<br>[`gemini_rag_service.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/packages/p6_inteligencia_analitica/services/gemini_rag_service.py) | **Web Vercel:** En *Reportes con IA*, consultar top 10 productos en 3 meses por sucursal. |
| **7** | **Capítulo V**<br>(Págs. 176-190) | [`backend/tests/test_garment_exchange.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/tests/test_garment_exchange.py)<br>[`backend/tests/test_tenant_isolation.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/tests/test_tenant_isolation.py)<br>[`backend/tests/test_offline_idempotency.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/tests/test_offline_idempotency.py) | **Terminal en Vivo:** Ejecutar comando `pytest` (100% verde / 3 passed). |

---

## 🏛️ PREGUNTA 1: Proceso de Metodología ICONIX (4 Etapas) y Evolución SaaS Multitenant

### A. Lo que pide la pregunta:
Explicar las 4 etapas principales de ICONIX utilizando el documento y demostrar con el software cómo evolucionó el sistema hacia una plataforma SaaS Multitenant.

### B. Lo que se necesita en el Documento Word (`2doParcial-Informe-grupo-46.docx`):
* **Capítulo 1.6 (Página 17) — Metodología de Desarrollo ICONIX:**
  Explica las 4 etapas del ciclo de vida de desarrollo ágil:
  1. *Análisis de Requisitos* (Fichas descriptivas de Casos de Uso y Modelo de Dominio inicial).
  2. *Análisis Preliminar / Robustez* (Diagramas BCE identificando Fronteras, Controles y Entidades; la regla sagrada exige que bucles y validaciones partan exclusivamente del Controlador).
  3. *Diseño Detallado* (Diagramas de Secuencia y Diagrama de Clases de diseño).
  4. *Implementación y Pruebas* (Estructuración modular de código y homologación con pruebas automatizadas).
* **Capítulo 2.1.1 (Página 19) — Enfoque Arquitectónico SaaS Multitenant:**
  Describe la transición de 1 tienda aislada (1er parcial) a un software multitienda donde cada empresa opera bajo aislamiento lógico mediante la clave foránea `tenant_id`.
* **Casos de Uso en el Word:**
  - **`CU01` (Pág. 43):** *Registrar y Gestionar Empresas (Tenants)*.
  - **`CU02` (Pág. 44):** *Gestionar Planes de Suscripción (Básico, Pro, Empresarial) y Cuotas*.
  - **`CU04` (Pág. 48):** *Gestionar Sucursales Bajo Límites del Plan*.

### C. Ver Software (Repositorio Local):
* **Entidades SaaS en Backend:**
  - [`backend/app/packages/p0_saas_plataforma/models/company.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/packages/p0_saas_plataforma/models/company.py): Entidad `Company` con `subdomain`, `nit_rut` y relación a `SubscriptionPlan`.
  - [`backend/app/packages/p0_saas_plataforma/models/subscription_plan.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/packages/p0_saas_plataforma/models/subscription_plan.py): Define los límites de negocio (`max_branches`, `ai_enabled`).
* **Seguridad y Aislamiento en Repositorio:**
  - [`backend/app/auth/security.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/auth/security.py): Función de inyección `get_current_active_user` que extrae el `tenant_id` del token JWT verificado.
  - [`backend/app/packages/p2_gestion_productos_catalogo/services/catalog_service.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/packages/p2_gestion_productos_catalogo/services/catalog_service.py): Muestra que cualquier consulta a base de datos lleva `WHERE Product.tenant_id == current_user.tenant_id`.

### D. Probar (Accionar el Caso de Uso en Vivo en Web Vercel):
1. Abre el navegador en la URL de producción de Vercel e inicia sesión con el administrador de **Boutique Elegance**:
   - Usuario: `admin@elegance.com` | Contraseña: `Tiendafashion123!`
   - En el menú lateral haz clic en **Sucursales**: Muestra que figuran sus **7 sucursales activas** y el plan Profesional.
2. Cierra sesión de inmediato.
3. Inicia sesión con el administrador de **Moda Urbana**:
   - Usuario: `admin@modaurbana.com` | Contraseña: `Tiendafashion123!`
   - En el menú lateral haz clic en **Sucursales**: Muestra que **únicamente aparece 1 sucursal activa** (Casco Viejo) y que su catálogo de ropa es completamente ajeno al de Boutique Elegance.
* **Evaluación:** **100% ADECUADO.** Demuestra en vivo el aislamiento lógico de datos entre tenants sobre la misma base de datos en Neon.

---

## 📝 PREGUNTA 3: Identificación de Actores, Precondiciones, Flujo Principal, Alternativos y Postcondiciones

### A. Lo que pide la pregunta:
Seleccionar un caso de uso (ej. Registrar una venta offline) y explicar cómo se identificaron sus actores, precondiciones, flujo principal, flujos alternativos y postcondiciones bajo la metodología ICONIX.

### B. Lo que se necesita en el Documento Word (`2doParcial-Informe-grupo-46.docx`):
* **Capítulo 2.2 (Página 23) — Identificación de Actores:**
  Clasifica al *Cajero/Vendedor POS* (Actor Principal) y al *Motor de Persistencia Local SQLite / IndexedDB* (Actor Secundario / del Sistema).
* **Capítulo 2.6 (Página 62) — Ficha Formal del Caso de Uso:**
  **`CU13: Registrar Venta POS Desconectada en Efectivo con Contingencia UUIDv4`**:
  - **Actores:** Cajero (iniciador) y Motor Local SQLite/IndexedDB (soporte).
  - **Precondiciones:** 1) Sesión iniciada previamente con red (JWT en caché); 2) Catálogo de prendas y stock base sincronizado en local; 3) Pago exclusivo en **Efectivo** (prohibición de pasarelas electrónicas sin red).
  - **Flujo Principal (10 pasos):** Selección de prendas $\rightarrow$ detección de red desconectada $\rightarrow$ selección forzada de Efectivo $\rightarrow$ cálculo de cambio $\rightarrow$ generación de `client_transaction_id` (UUIDv4) $\rightarrow$ descuento de stock en SQLite $\rightarrow$ inserción en tabla local con estado `PENDIENTE_SYNC` $\rightarrow$ emisión de comprobante provisional.
  - **Flujos Alternativos:** FA-1 (Intento de cobro con tarjeta bloqueado por sistema); FA-2 (Quiebre de stock local); FA-3 (Cancelación).
  - **Postcondiciones:** Venta guardada localmente con UUIDv4, stock local rebajado y encolada para sincronización.

### C. Ver Software (Repositorio Local):
* **Capa Móvil (Flutter):**
  - [`mobile/lib/features/offline/database/database_service.dart`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/mobile/lib/features/offline/database/database_service.dart): Código DDL que crea en SQLite las tablas locales `offline_sales` y `offline_sale_items` con `client_transaction_id TEXT PRIMARY KEY` y `sync_status TEXT DEFAULT 'PENDIENTE_SYNC'`.
* **Capa Backend:**
  - [`backend/app/packages/p5_gestion_ventas_pos/models/pos_order.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/packages/p5_gestion_ventas_pos/models/pos_order.py): Modelo relacional con campos `client_transaction_id = Column(UUID, unique=True)` y `sync_status`.

### D. Probar (Accionar el Caso de Uso en Vivo en Mobile Offline):
1. Toma el teléfono físico con la APK FashionStore instalada.
2. Desliza la barra superior de Android y **ACTIVA EL MODO AVIÓN** (desconecta WiFi y datos móviles).
3. Entra con la cajera de Boutique Elegance:
   - Usuario: `cajera.lp@fashionstore.bo` | Contraseña: `Tiendafashion123!`
4. En la pantalla POS, agrega 1 prenda al carrito (ej. Blusa Casual Talla S - Bs 45).
5. Toca "Cobrar": Observa que la opción Tarjeta está deshabilitada y está seleccionado **Efectivo**.
6. Presiona **Registrar Venta**: Se emite el comprobante en pantalla con el mensaje verde *"Venta guardada localmente (Modo Offline)"* y se visualiza el UUIDv4 generado.
* **Evaluación:** **100% ADECUADO.** Cumple punto por punto con la ficha técnica y la ejecución sin red.

---

## ⚡ PREGUNTA 4: Registro de Venta al Contado Offline, Información Almacenada y Reconexión

### A. Lo que pide la pregunta:
Explicar paso a paso cómo se registra la venta al contado localmente cuando no hay internet, qué información exacta se almacena y qué sucede cuando vuelve la conectividad.

### B. Lo que se necesita en el Documento Word (`2doParcial-Informe-grupo-46.docx`):
* **Capítulo 2.4.3 (Página 35) — Políticas de Operación Offline e Idempotencia:**
  Detalla la regla de cobro en efectivo, generación local de identificadores y el protocolo de no duplicidad.
* **Fichas de Casos de Uso:**
  - **`CU13` (Pág. 62):** Registro de venta offline.
  - **`CU14` (Pág. 64):** *Gestionar Bandeja Local de Operaciones Pendientes (Outbox PWA / SQLite)*.
  - **`CU15` (Pág. 65):** *Sincronizar Lotes de Ventas con Idempotencia Central (sync_operations)*.
* **Capítulo 3.5.7 (Página 142) — Diseño Físico de Datos:**
  Muestra la tabla central `sync_operations` con sus campos (`client_transaction_id`, `tenant_id`, `status`, `synced_at`).

### C. Ver Software (Repositorio Local):
* **En el Móvil (Flutter):**
  - [`mobile/lib/features/offline/services/sync_service.dart`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/mobile/lib/features/offline/services/sync_service.dart): Método `syncPendingSales()` que consulta las ventas con `sync_status = 'PENDIENTE_SYNC'` y las empaqueta en JSON hacia `/api/sales/offline/batch-sync`.
* **En el Backend (FastAPI):**
  - [`backend/app/packages/p5_gestion_ventas_pos/routes/offline_sync_router.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/packages/p5_gestion_ventas_pos/routes/offline_sync_router.py):
    Muestra la validación de idempotencia:
    ```python
    existing = db.query(SyncOperation).filter_by(client_transaction_id=sale.client_transaction_id).first()
    if existing:
        results.append({"client_transaction_id": sale.client_transaction_id, "status": "ALREADY_PROCESSED"})
        continue
    ```

### D. Probar (Accionar la Prueba Cruzada Móvil Offline $\rightarrow$ Web Vercel):
1. **Paso 1 (En Celular sin red):** Muestra en la pantalla de la app el indicador: **"1 Venta Pendiente de Sincronización"**.
2. **Paso 2 (Reconexión):** Desactiva el Modo Avión en el celular (se reconecta a WiFi o Datos).
3. **Paso 3 (Sincronización):** Presiona el botón "Sincronizar": el contador baja de 1 a 0 y la orden pasa a estado verde *"Sincronizado con Éxito"*.
4. **Paso 4 (Verificación en Vercel):** En tu laptop, en la página web desplegada en Vercel, entra a **Historial de Ventas** y refresca la vista: muestra al docente que la venta efectuada en el celular ya figura en la base de datos central en Neon con su fecha, sucursal, productos y monto exacto.
* **Evaluación:** **100% ADECUADO.** Se demuestra el ciclo completo de captura offline, transporte por lote e inserción idempotente.

---

## 🤖 PREGUNTA 6: Módulo de Reportes Generativos con IA, NLU y Datos Reales de 3 Meses

### A. Lo que pide la pregunta:
Explicar cómo funciona el módulo de reportes generativos ante una consulta en lenguaje natural (ej. *"Mostrar los 10 productos más vendidos durante los últimos 3 meses agrupados por sucursal"*). ¿Cómo interpreta el sistema la solicitud? y ¿Cómo se obtienen los datos reales?

### B. Lo que se necesita en el Documento Word (`2doParcial-Informe-grupo-46.docx`):
* **Capítulo 1.5 - Módulo 7 (Página 15):** Módulo de Inteligencia Artificial, Analítica y Reportes Generativos.
* **Capítulo 2.6 (Página 73) — Ficha Formal del Caso de Uso:**
  **`CU20: Generar Reportes Ejecutivos por Voz y Lenguaje Natural (Gemini RAG)`** *(Recuerda: en el Word está catalogado como CU20)*.
  - Describe la arquitectura RAG (Retrieval-Augmented Generation) con Google Gemini 1.5 Pro.
  - Explica la política de seguridad: el LLM **JAMÁS** ejecuta SQL directo; extrae parámetros JSON tipados para evitar inyecciones.
* **Capítulo 3.2 (Página 94) y 3.3 (Página 115):** Diagramas de Robustez y Secuencia del pipeline RAG asistido por metadatos.

### C. Ver Software (Repositorio Local):
* **Endpoint de Reportes:**
  - [`backend/app/packages/p6_inteligencia_analitica/routes/generative_reports_router.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/packages/p6_inteligencia_analitica/routes/generative_reports_router.py): Endpoint que recibe el prompt en lenguaje natural.
* **Servicio NLU y Consulta Determinista:**
  - [`backend/app/packages/p6_inteligencia_analitica/services/gemini_rag_service.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/app/packages/p6_inteligencia_analitica/services/gemini_rag_service.py): Muestra:
    1. El *System Prompt* de gobernanza que fuerza a Gemini a responder en formato JSON.
    2. La consulta SQLAlchemy ORM que filtra por `Order.tenant_id == current_user.tenant_id`, `Order.created_at >= hoy - 90 días` y agrupa por `Branch.name, Product.name`.

### D. Probar (Accionar el Caso de Uso en Vivo en Web Vercel):
1. Inicia sesión en Vercel con el administrador de Boutique Elegance:
   - Usuario: `admin@elegance.com` | Contraseña: `Tiendafashion123!`
2. En el menú lateral selecciona **Reportes con IA / Asistente Analítico**.
3. En la caja de chat escribe textualmente:
   *"Mostrar los 10 productos más vendidos durante los últimos 3 meses agrupados por sucursal"*
4. Presiona Enviar: en 1.8 segundos la pantalla renderiza:
   - La **tabla relacional de datos de PostgreSQL** con el ranking y cantidades.
   - El **gráfico interactivo de barras** comparativo por sucursal.
   - La **síntesis analítica** redactada por Gemini.
5. Haz clic en el icono del altavoz para reproducir el informe por voz (Text-to-Speech).
* **Evaluación:** **100% ADECUADO.** Funciona sobre los más de 2,200 pedidos reales de los últimos 90 días cargados en la base de datos de Neon.

---

## 🧪 PREGUNTA 7: Homologación de Requisitos con 3 Pruebas Críticas

### A. Lo que pide la pregunta:
Demostrar el cumplimiento de los requisitos funcionales y no funcionales del enunciado mediante la selección de 3 pruebas críticas, explicando su procedimiento, datos utilizados, resultado esperado y resultado obtenido.

### B. Lo que se necesita en el Documento Word (`2doParcial-Informe-grupo-46.docx`):
* **Capítulo 2.3 (Páginas 24 a 32):** Matriz oficial de Requisitos Funcionales (`RF01` al `RF35`) y Requisitos No Funcionales (`RNF01` al `RNF15`).
* **Capítulo V (Páginas 176 a 190) — Pruebas y Resultados:**
  Contiene el Plan de Pruebas (5.1), Pruebas Funcionales (5.2), Pruebas de Integración (5.3), Corrección de Errores (5.4) y Casos de Prueba formales con la plantilla de caja negra.
* **Documento de Respaldo en Repo:** [`docs/informes/CAPITULO_V_PRUEBAS_Y_CONCLUSIONES.md`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/docs/informes/CAPITULO_V_PRUEBAS_Y_CONCLUSIONES.md) (incluye los 42 casos de prueba homologados).

### C. Ver Software (Repositorio Local):
Muestra los 3 archivos de prueba automatizada en backend:
1. **Prueba 1 (Funcional - Cambio de Prenda por Talla CU17):**
   - [`backend/tests/test_garment_exchange.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/tests/test_garment_exchange.py): Procedimiento con Talla M (Bs 50) cambiada por Talla L (Bs 70). Valida que solo se apruebe si se abonan los Bs 20 de diferencia; de lo contrario, responde 400 Bad Request.
2. **Prueba 2 (No Funcional - Seguridad y Aislamiento Multitenant):**
   - [`backend/tests/test_tenant_isolation.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/tests/test_tenant_isolation.py): Token JWT de Moda Urbana intentando acceder a una sucursal de Boutique Elegance. Valida respuesta HTTP 404/403 sin exposición de datos.
3. **Prueba 3 (No Funcional - Idempotencia Offline CU15):**
   - [`backend/tests/test_offline_idempotency.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/backend/tests/test_offline_idempotency.py): Dos llamadas consecutivas con idéntico `client_transaction_id`. Valida que la segunda llamada responda `ALREADY_PROCESSED` sin duplicar el descuento de stock.

### D. Probar (Accionar la Demostración en Terminal en Vivo):
Frente al tribunal, abre la terminal PowerShell en la carpeta raíz y ejecuta:
```powershell
pytest tests/test_garment_exchange.py tests/test_tenant_isolation.py tests/test_offline_idempotency.py -v
```
* **Resultado Observable:** La consola ejecuta las aserciones en 1.5 segundos y muestra en verde:
  ```text
  tests/test_garment_exchange.py::test_garment_exchange_with_difference PASSED [ 33%]
  tests/test_tenant_isolation.py::test_cross_tenant_access_blocked PASSED     [ 66%]
  tests/test_offline_idempotency.py::test_duplicate_sync_idempotency PASSED   [100%]
  ====== 3 passed in 1.45s ======
  ```
* **Evaluación:** **100% ADECUADO.** Homologación automatizada e irrefutable frente a los docentes.

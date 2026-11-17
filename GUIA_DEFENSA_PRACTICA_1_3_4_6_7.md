# GUÍA PRÁCTICA DE DEFENSA — PREGUNTAS 1, 3, 4, 6 Y 7
### FashionStore — Plataforma E-Commerce SaaS Multitenant
**Materia:** Sistemas de Información 2 (2do Parcial)  
**Metodología:** ICONIX (UML 2.5+) | **Arquitectura:** Deep Modules (7 Paquetes de Dominio) & Clean Architecture  
**Documento Oficial:** [`2doParcial-Informe-grupo-46.docx`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/2doParcial-Informe-grupo-46.docx)  
**Repositorio Local:** [`ecommerce-SI2`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/)  
**Software para Pruebas:** Web PC Angular PWA | APK Móvil Android en Celular Físico ([`FashionStore-release.apk`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/FashionStore-release.apk))

---

## 🔑 TABLA MAESTRA DE CREDENCIALES POR APARTADO Y ROL

> [!IMPORTANT]
> **Contraseña universal para todas las cuentas de prueba:** `Tiendafashion123!`

| Nivel / Rol | Empresa (Tenant) | Correo de Acceso | Contraseña | Uso en la Defensa |
| :--- | :--- | :--- | :--- | :--- |
| **Superadmin Plataforma** | Central SaaS | `superadmin@fashionstore.com` | `Tiendafashion123!` | **Pregunta 1:** Gestión global de empresas contratantes (`/app/superadmin/tenants`) y planes (`/app/superadmin/plans`). |
| **Administrador** | **Boutique Elegance**<br>*(Plan Profesional - con IA)* | `admin@elegance.com` | `Tiendafashion123!` | **Pregunta 1:** Ver sus 7 sucursales activas.<br>**Pregunta 6:** Reportes por voz y Gemini RAG en Web PC. |
| **Encargado Sucursal** | **Boutique Elegance** | `encargado.lp@fashionstore.bo` | `Tiendafashion123!` | **Pregunta 6:** Consultar reportes ejecutivos y resolución de discrepancias de sucursal. |
| **Cajera / POS** | **Boutique Elegance** | `cajera.lp@fashionstore.bo` | `Tiendafashion123!` | **Pregunta 3 y 4:** Cobro offline en efectivo en caja POS web y emisión de ticket con UUIDv4. |
| **Cliente Móvil** | **Boutique Elegance** | `nicole.castillomontero.elegance@cliente.bo`<br>*(o botón rápido en login)* | `Tiendafashion123!` | **Pregunta 4:** Catálogo desconectado, reserva de prenda offline en SQLite y sincronización. |
| **Administrador** | **Moda Urbana**<br>*(Plan Básico - sin IA)* | `admin@modaurbana.com` | `Tiendafashion123!` | **Pregunta 1:** Ver aislamiento estricto (1 sola sucursal).<br>**Pregunta 6:** Demostrar rechazo defensivo `HTTP 403` por política de planes sin IA. |
| **Cliente Móvil** | **Moda Urbana** | `valeria.méndezroca.modaurbana@cliente.bo` | `Tiendafashion123!` | **Pregunta 1:** Catálogo independiente exclusivo de Moda Urbana sin contaminación de prendas. |
| **Administrador** | **Boutique París**<br>*(Plan Empresarial)* | `admin@boutiqueparis.com` | `Tiendafashion123!` | **Pregunta 1:** Tenant con plan de máxima escala (hasta 20 sucursales y cuota ilimitada). |

---

## 📌 MATRIZ RESUMEN DE LA TRÍADA DE DEFENSA

| Pregunta | Caso de Uso Oficial en Word | Ver Software (Repositorio Local) | Probar en Vivo (Web PC / Celular Físico) | Credenciales Clave |
| :---: | :--- | :--- | :--- | :--- |
| **1** | **`CU01`, `CU02`, `CU04`**<br>(Págs. 17, 19, 44, 48) | [`p0_saas_plataforma/`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/packages/p0_saas_plataforma/)<br>[`backend/app/auth/security.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/auth/security.py) | **Web PC:** Alternar sesión entre Boutique Elegance (7 sucursales) y Moda Urbana (1 sucursal). Demostrar cuotas de planes. | Admin Elegance:<br>`admin@elegance.com`<br>Admin Moda Urbana:<br>`admin@modaurbana.com` |
| **3** | **`CU13`**<br>(Pág. 62) | [`caja-page.component.ts`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/frontend/src/app/features/cajero/pages/caja-page.component.ts)<br>[`sales_service.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/packages/p5_gestion_ventas_pos/services/sales_service.py) | **Web POS:** Desconectar red, cobrar exclusivamente en **Efectivo** $\rightarrow$ Generación de comprobante con UUIDv4. | Cajera:<br>`cajera.lp@fashionstore.bo` |
| **4** | **`CU08`, `CU11`, `CU14`, `CU15`**<br>(Págs. 35, 62, 64, 65, 142) | [`local_catalog_db.dart`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/mobile/lib/core/storage/local_catalog_db.dart)<br>[`reservation_create_page.dart`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/mobile/lib/features/reservations/reservation_create_page.dart)<br>[`sales_service.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/packages/p5_gestion_ventas_pos/services/sales_service.py) | **Móvil en Celular Físico:** Modo Avión $\rightarrow$ Catálogo con imágenes cacheadas en disco $\rightarrow$ Selección de fecha/sucursal $\rightarrow$ SQLite `local_pending_reservations` $\rightarrow$ Reconectar y sincronizar. | Cliente Móvil:<br>`nicole.castillomontero.elegance@cliente.bo` |
| **6** | **`CU20`**<br>(Pág. 73) | [`voice_report_routes.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/packages/p6_inteligencia_analitica/routes/voice_report_routes.py)<br>[`gemini_rag_service.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/packages/p6_inteligencia_analitica/services/gemini_rag_service.py)<br>[`voice-assistant-modal.component.html`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/frontend/src/app/features/admin/components/voice-assistant-modal.component.html) | **Web PC:** En *Reportes Empresariales*, pulsar `🎙️ Asistente por Voz (IA)` y consultar el top 10 de productos en los últimos 3 meses por sucursal. | Admin Elegance:<br>`admin@elegance.com`<br>Encargado:<br>`encargado.lp@fashionstore.bo` |
| **7** | **Capítulo V**<br>(Págs. 176-190) | [`test_cu13_offline_pos_sales.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/tests/test_cu13_offline_pos_sales.py)<br>[`test_cu15_batch_sync_idempotency.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/tests/test_cu15_batch_sync_idempotency.py)<br>[`test_cu20_voice_rag_reports.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/tests/test_cu20_voice_rag_reports.py) | **Terminal en Vivo:** Ejecutar comando `py -3 -m pytest` ejecutando 15 pruebas críticas automatizadas en verde (100% passed). | Credenciales inyectadas por JWT en fixtures de test. |

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
  - [`backend/app/packages/p0_saas_plataforma/models/company.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/packages/p0_saas_plataforma/models/company.py): Entidad `Company` con `subdomain`, `nit_rut` y relación a `Subscription`.
  - [`backend/app/packages/p0_saas_plataforma/models/plan.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/packages/p0_saas_plataforma/models/plan.py): Define los límites de negocio (`max_branches`: 2 en Básico, 10 en Pro, 20 en Empresarial; `has_ai_access`).
* **Seguridad y Aislamiento en Repositorio:**
  - [`backend/app/auth/dependencies.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/auth/dependencies.py): Inyección de dependencias que extrae el `tenant_id` obligatorio del token JWT.
  - [`backend/app/packages/p1_gestion_usuarios_acceso/routes/branch_routes.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/packages/p1_gestion_usuarios_acceso/routes/branch_routes.py): Endpoint `/api/branches/quota` que valida en tiempo real que las sucursales creadas no superen la cuota contratada.

### D. Probar en Vivo (Web PC):
1. **Credenciales para Boutique Elegance (Plan Profesional):**
   - **Usuario:** `admin@elegance.com` | **Contraseña:** `Tiendafashion123!`
   - En el menú lateral haz clic en **Sucursales**: Demuestra que figuran sus **7 sucursales activas** y el plan Profesional.
2. Cierra sesión.
3. **Credenciales para Moda Urbana (Plan Básico):**
   - **Usuario:** `admin@modaurbana.com` | **Contraseña:** `Tiendafashion123!`
   - En el menú lateral haz clic en **Sucursales**: Demuestra que **únicamente aparece 1 sucursal activa** (Casco Viejo) y que el catálogo de prendas es completamente independiente.
4. **Credenciales de Superadmin (Portal Global):**
   - **Usuario:** `superadmin@fashionstore.com` | **Contraseña:** `Tiendafashion123!`
   - Accede a `/app/superadmin/tenants` y `/app/superadmin/plans`: Demuestra la gestión centralizada de empresas contratantes y asignación de planes SaaS.
* **Evaluación:** **100% ADECUADO.** Demuestra en vivo el aislamiento lógico de datos entre tenants sobre la misma base de datos relacional.

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
  - **Precondiciones:** 1) Sesión iniciada previamente con red (JWT en almacenamiento local); 2) Catálogo de prendas y precios descargado en local; 3) Pago exclusivo en **Efectivo** (prohibición de pasarelas electrónicas sin conexión).
  - **Flujo Principal (10 pasos):** Selección de prendas $\rightarrow$ detección de red desconectada $\rightarrow$ selección forzada de Efectivo $\rightarrow$ cálculo de vuelto $\rightarrow$ generación de `client_sale_id` (UUIDv4) $\rightarrow$ registro en almacenamiento local con estado `synced = false` $\rightarrow$ emisión de comprobante provisional de contingencia.
  - **Flujos Alternativos:** FA-1 (Intento de cobro con tarjeta bloqueado por sistema); FA-2 (Monto entregado insuficiente); FA-3 (Cancelación).
  - **Postcondiciones:** Venta guardada localmente con UUIDv4 único y encolada para sincronización central.

### C. Ver Software (Repositorio Local):
* **Capa Frontend Web (PWA):**
  - [`frontend/src/app/features/cajero/pages/caja-page.component.ts`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/frontend/src/app/features/cajero/pages/caja-page.component.ts): Método `submitSale()` que valida `isOfflineEffective()`, genera `crypto.randomUUID()`, fuerza `payment_method = 'cash'` y delega a `idbSales.savePending()`.
  - [`frontend/src/app/core/offline/idb-sales.service.ts`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/frontend/src/app/core/offline/idb-sales.service.ts): Almacena las ventas en cola bajo la clave `fashionstore_pending_pos_sales`.
* **Capa Backend (FastAPI):**
  - [`backend/app/packages/p5_gestion_ventas_pos/models/sale.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/packages/p5_gestion_ventas_pos/models/sale.py): Campos `client_sale_id = Column(UUID, unique=True)` y `is_offline = Column(Boolean, default=False)`.

### D. Probar en Vivo (Web POS):
1. **Credenciales de Cajera:**
   - **Usuario:** `cajera.lp@fashionstore.bo` | **Contraseña:** `Tiendafashion123!`
2. Abre la terminal de punto de venta `/app/cajero/caja`.
3. Abre las herramientas de desarrollador del navegador (F12) $\rightarrow$ Pestaña **Network** $\rightarrow$ Cambia a **Offline** (o desconecta el cable/WiFi).
4. Agrega 2 prendas al carrito de compras.
5. Observa que el sistema inhabilita pagos electrónicos y fuerza **Efectivo**.
6. Ingresa el monto en efectivo y haz clic en **Registrar Venta**:
   - Se muestra el modal de comprobante de contingencia con el código de ticket y el UUIDv4 local.
   - La venta queda registrada en la cola local con indicador de pendiente de sincronización.
* **Evaluación:** **100% ADECUADO.** Cumple punto por punto con la ficha técnica de ICONIX.

---

## ⚡ PREGUNTA 4: Registro Offline (Móvil y Web), Información Almacenada y Reconexión

### A. Lo que pide la pregunta:
Explicar paso a paso cómo se registra una operación localmente cuando no hay internet (venta al contado o reserva de prendas), qué información exacta se almacena y qué sucede cuando vuelve la conectividad.

### B. Lo que se necesita en el Documento Word (`2doParcial-Informe-grupo-46.docx`):
* **Capítulo 2.4.3 (Página 35) — Políticas de Operación Offline e Idempotencia:**
  Detalla la regla de cobro en efectivo, persistencia local con SQLite/IndexedDB y el protocolo central de no duplicidad (`sync_operations`).
* **Fichas de Casos de Uso:**
  - **`CU08` (Pág. 54):** *Consultar Catálogo Offline en Modo Desconectado*.
  - **`CU11` (Pág. 58):** *Registrar Reserva de Prendas Offline en Modo Desconectado (SQLite)*.
  - **`CU13` (Pág. 62):** *Registrar Venta POS Desconectada en Efectivo*.
  - **`CU14` (Pág. 64):** *Gestionar Bandeja Local de Operaciones Pendientes*.
  - **`CU15` (Pág. 65):** *Sincronizar Lotes con Idempotencia Central*.
* **Capítulo 3.5.7 (Página 142) — Diseño Físico de Datos:**
  Muestra la tabla central `sync_operations` (`client_operation_id`, `tenant_id`, `status`, `synced_at`).

### C. Ver Software (Repositorio Local):
* **En la App Móvil (Flutter):**
  - [`mobile/lib/core/storage/local_catalog_db.dart`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/mobile/lib/core/storage/local_catalog_db.dart): Esquema SQLite local con tablas `local_catalog_products`, `local_catalog_variants`, `local_branches` y `local_pending_reservations`.
  - [`mobile/lib/core/storage/local_image_cache.dart`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/mobile/lib/core/storage/local_image_cache.dart): Caché persistente en disco físico para imágenes textiles que evita pérdidas de visualización offline.
  - [`mobile/lib/features/reservations/reservation_create_page.dart`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/mobile/lib/features/reservations/reservation_create_page.dart): Selector interactivo de fecha de visita (chips rápidos "Hoy", "Mañana", "En 2 días" o calendario) y persistencia offline directa en SQLite.
* **En el Backend (FastAPI):**
  - [`backend/app/packages/p5_gestion_ventas_pos/services/sales_service.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/packages/p5_gestion_ventas_pos/services/sales_service.py): Función `batch_sync_offline_sales()` que verifica contra `sync_operations` para garantizar idempotencia estricta.

### D. Probar en Vivo (Demostración en Celular Físico con APK):

#### Credenciales para la prueba móvil:
- **Cliente:** `nicole.castillomontero.elegance@cliente.bo` | **Contraseña:** `Tiendafashion123!`  
  *(o presiona el botón rápido de login de cliente en la app)*.

#### Procedimiento Paso a Paso:
1. **Precarga (Con Conexión):** Abre la APK [`FashionStore-release.apk`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/ecommerce-SI2/FashionStore-release.apk) con internet e inicia sesión como cliente. Navega 5 segundos por el catálogo para descargar productos e imágenes al almacenamiento local SQLite y disco.
2. **Desconexión Total:** **Activa el Modo Avión** en tu celular (sin WiFi ni datos).
3. **Navegación Offline:** Entra al catálogo; observa que las prendas y fotografías se cargan al 100% desde disco local sin conexión.
4. **Detalle y Reserva:** Toca cualquier prenda (ej. Vestido o Blusa), selecciona talla y color, y pulsa **"Reservar prenda"**.
5. **Preparación de Reserva:** La app abre de inmediato la pantalla de reserva:
   - Selecciona la sucursal.
   - Elige la **Fecha de visita a la tienda** mediante los chips rápidos (**"Hoy"**, **"Mañana"**, **"En 2 días"**) o el calendario.
6. **Guardado Offline:** Pulsa **"Guardar reserva offline"**.
   - Mensaje verde de éxito: *"Reserva guardada offline en el dispositivo. Sincronízala al reconectar."*
   - En **"Mis reservas"** aparece la tarjeta con la etiqueta naranja **`PENDIENTE DE SINCRONIZAR`**, la foto de la prenda y el total en Bs.
7. **Reconexión y Sincronización:**
   - **Desactiva el Modo Avión** (vuelve a tener internet).
   - En *"Mis reservas"*, pulsa **"Sincronizar"**.
   - El backend en Neon recibe la operación, la registra con idempotencia y el estado cambia a 🟢 **`CONFIRMADA / ACTIVA`**.
* **Evaluación:** **100% ADECUADO.** Cumple el ciclo integral de persistencia local SQLite, tolerancia a fallos y transporte idempotente.

---

## 🤖 PREGUNTA 6: Módulo de Reportes Generativos con IA, NLU y Datos Reales de 3 Meses

### A. Lo que pide la pregunta:
Explicar cómo funciona el módulo de reportes generativos ante una consulta en lenguaje natural (ej. *"Mostrar los 10 productos más vendidos durante los últimos 3 meses agrupados por sucursal"*). ¿Cómo interpreta el sistema la solicitud? y ¿Cómo se obtienen los datos reales?

### B. Lo que se necesita en el Documento Word (`2doParcial-Informe-grupo-46.docx`):
* **Capítulo 1.5 - Módulo 7 (Página 15):** Módulo de Inteligencia Artificial, Analítica y Reportes Generativos.
* **Capítulo 2.6 (Página 73) — Ficha Formal del Caso de Uso:**
  **`CU20: Generar Reportes Ejecutivos por Voz y Lenguaje Natural (Gemini RAG)`**:
  - Arquitectura RAG (Retrieval-Augmented Generation) con Google Gemini 2.5 Flash y motor analítico local de contingencia.
  - Política de seguridad: El LLM **NUNCA** ejecuta SQL arbitrario; el backend consulta PostgreSQL con filtros estrictos de `tenant_id` y ventana de 90 días, e inyecta el JSON resultante en el prompt del sistema.
* **Capítulo 3.2 y 3.3:** Diagramas de Robustez y Secuencia del pipeline RAG multitenant.

### C. Ver Software (Repositorio Local):
* **Endpoints de Asistente Ejecutivo por Voz:**
  - [`backend/app/packages/p6_inteligencia_analitica/routes/voice_report_routes.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/packages/p6_inteligencia_analitica/routes/voice_report_routes.py):
    - `POST /api/reports/voice-query`: Procesa la consulta por voz o texto bajo JWT (`tenant_id`).
    - `GET /api/reports/voice-query/capabilities`: Retorna estado de IA y las preguntas interactivas sugeridas.
* **Pipeline RAG y Agregación de 90 Días por Sucursal:**
  - [`backend/app/packages/p6_inteligencia_analitica/services/gemini_rag_service.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/app/packages/p6_inteligencia_analitica/services/gemini_rag_service.py):
    - `build_tenant_rag_context()`: Consulta las ventas completadas del tenant, calcula métricas de los últimos 90 días y ejecuta la agregación SQL del **Top 10 de productos por sucursal** con unidades vendidas y recaudación en Bs.
    - `_call_gemini_rag_sync()`: Envía a Gemini el prompt con las reglas ejecutivas y el esquema estructurado `VoiceReportResponse`.
    - `_generate_heuristic_fallback()`: Motor local de alta disponibilidad que genera KPIs y tabla tabular incluso sin conexión externa a Gemini.
* **Interfaz de Usuario Web:**
  - [`frontend/src/app/features/admin/components/voice-assistant-modal.component.html`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/frontend/src/app/features/admin/components/voice-assistant-modal.component.html): Modal interactivo con animación de ondas de voz, chips sugeridos, KPIs, tabla `data_preview` y botón de locución TTS.

### D. Probar en Vivo (Web PC):

#### Credenciales para la prueba:
- **Tenant con IA activa (Boutique Elegance):**  
  - Administrador: `admin@elegance.com` | `Tiendafashion123!`  
  - Encargado: `encargado.lp@fashionstore.bo` | `Tiendafashion123!`
- **Tenant sin IA para demostrar bloqueo de Plan Básico (Moda Urbana):**  
  - Administrador: `admin@modaurbana.com` | `Tiendafashion123!`

#### Procedimiento Paso a Paso:
1. Inicia sesión en la Web PC como Administrador de **Boutique Elegance** (`admin@elegance.com`).
2. En el menú lateral haz clic en **"Reportes"** (`/app/admin/reports`).
3. En la barra superior haz clic en el botón índigo **`🎙️ Asistente por Voz (IA)`**.
4. Se abre el modal del asistente ejecutivo:
   - Haz clic directo en el primer chip sugerido:  
     💬 **`Top 10 productos más vendidos en los últimos 3 meses por sucursal`**  
     *(o pulsa el Micrófono para dictarlo por voz, o escríbelo en el campo inferior)*.
5. **Resultado en Pantalla (en 1.5 segundos):**
   - **Insignia del Modelo:** Badge verde `✨ Gemini 2.5 Flash`.
   - **Resumen Ejecutivo:** Diagnóstico narrativo directivo de los últimos 90 días.
   - **Tarjetas KPI:** *Top 10 Prendas*, *Unidades Vendidas*, *Facturación Top 10 en Bs* y *Sucursal Líder*.
   - **Tabla Detallada:** Filas estructuradas con columnas: `Sucursal`, `Prenda`, `Talla`, `Unidades` y `Total Facturado`.
   - **Locución Sonora:** Haz clic en **`🔊 Escuchar Resumen`** para que el navegador lea el reporte en español en voz alta.
6. **Demostración de Política de Planes (Plan Básico Bloqueado):**
   - Cierra sesión e ingresa como Administrador de **Moda Urbana** (`admin@modaurbana.com`).
   - Abre el Asistente por Voz: El sistema muestra el mensaje de bloqueo defensivo advirtiendo que el Plan Básico no cuenta con acceso a la IA Generativa (HTTP 403) y requiere migrar al Plan Profesional.
7. **Exportación Formal:** En la pantalla de Reportes, haz clic en **`📄 PDF Oficial`** o **`📊 Excel (.xlsx)`** para descargar el reporte membretado con los datos de la empresa.
* **Evaluación:** **100% ADECUADO.** Cumple con los requisitos de lenguaje natural, agregación trimestral por sucursal, aislamiento multitenant y exportación.

---

## 🧪 PREGUNTA 7: Homologación de Requisitos con 3 Pruebas Críticas

### A. Lo que pide la pregunta:
Demostrar el cumplimiento de los requisitos funcionales y no funcionales del enunciado mediante la selección de 3 pruebas críticas, explicando su procedimiento, datos utilizados, resultado esperado y resultado obtenido.

### B. Lo que se necesita en el Documento Word (`2doParcial-Informe-grupo-46.docx`):
* **Capítulo 2.3 (Páginas 24 a 32):** Matriz oficial de Requisitos Funcionales (`RF01` al `RF35`) y Requisitos No Funcionales (`RNF01` al `RNF15`).
* **Capítulo V (Páginas 176 a 190) — Pruebas y Resultados:**
  Plan de Pruebas (5.1), Pruebas Funcionales (5.2), Pruebas de Integración (5.3) y Casos de Prueba formales con la plantilla de caja negra.

### C. Ver Software (Repositorio Local):
Las pruebas automatizadas del proyecto en `backend/tests/` demuestran las reglas sagradas del examen:
1. **Prueba Crítica 1 (Funcional - Venta POS Desconectada CU13):**
   - [`backend/tests/test_cu13_offline_pos_sales.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/tests/test_cu13_offline_pos_sales.py): Verifica que la venta offline exija pago en efectivo, rechace pagos electrónicos sin conexión, genere `client_sale_id` y preserve aislamiento multitenant.
2. **Prueba Crítica 2 (No Funcional - Idempotencia Central de Lote CU15):**
   - [`backend/tests/test_cu15_batch_sync_idempotency.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/tests/test_cu15_batch_sync_idempotency.py): Sincroniza un lote de ventas offline y luego reenvía exactamente el mismo lote. Valida que `sync_operations` reconozca las transacciones ya procesadas (`ALREADY_PROCESSED`) sin duplicar ventas ni descontar inventario dos veces.
3. **Prueba Crítica 3 (Funcional / IA - Reportes Gemini RAG CU20):**
   - [`backend/tests/test_cu20_voice_rag_reports.py`](file:///d:/Proyectos%20si%202/SEGUNDO%20PARCIAL%20SI2/backend/tests/test_cu20_voice_rag_reports.py): Método `test_cu20_exam_question_top_10_by_branch_3_months`. Verifica la consulta por voz/texto de los 10 productos más vendidos en los últimos 3 meses por sucursal, el bloqueo del Plan Básico (403) y la resiliencia del motor analítico.

### D. Probar en Vivo (Demostración en Terminal):
Frente al docente, abre una terminal PowerShell en el directorio `backend` y ejecuta:
```powershell
cd backend
py -3 -m pytest tests/test_cu13_offline_pos_sales.py tests/test_cu15_batch_sync_idempotency.py tests/test_cu20_voice_rag_reports.py -v
```

* **Resultado Observable en Consola:**
```text
tests/test_cu13_offline_pos_sales.py::TestCU13OfflinePosSales::test_01_create_offline_sale_cash_success PASSED [  6%]
tests/test_cu13_offline_pos_sales.py::TestCU13OfflinePosSales::test_02_offline_sale_rejects_non_cash_payment PASSED [ 13%]
tests/test_cu13_offline_pos_sales.py::TestCU13OfflinePosSales::test_03_idempotent_duplicate_client_sale_id PASSED [ 20%]
tests/test_cu13_offline_pos_sales.py::TestCU13OfflinePosSales::test_04_tenant_isolation_cross_access_prevented PASSED [ 26%]
tests/test_cu13_offline_pos_sales.py::TestCU13OfflinePosSales::test_05_insufficient_stock_fails PASSED [ 33%]
tests/test_cu15_batch_sync_idempotency.py::TestCU15BatchSyncIdempotency::test_batch_sync_happy_path PASSED [ 40%]
tests/test_cu15_batch_sync_idempotency.py::TestCU15BatchSyncIdempotency::test_batch_sync_idempotency_duplicate_resend PASSED [ 46%]
tests/test_cu15_batch_sync_idempotency.py::TestCU15BatchSyncIdempotency::test_batch_sync_mixed_batch PASSED [ 53%]
tests/test_cu15_batch_sync_idempotency.py::TestCU15BatchSyncIdempotency::test_batch_sync_multitenant_isolation PASSED [ 60%]
tests/test_cu15_batch_sync_idempotency.py::TestCU15BatchSyncIdempotency::test_batch_sync_empty_operations PASSED [ 66%]
tests/test_cu20_voice_rag_reports.py::test_cu20_capabilities_endpoint PASSED [ 73%]
tests/test_cu20_voice_rag_reports.py::test_cu20_voice_query_success PASSED [ 80%]
tests/test_cu20_voice_rag_reports.py::test_cu20_voice_query_blocked_on_basic_plan PASSED [ 86%]
tests/test_cu20_voice_rag_reports.py::test_cu20_heuristic_fallback_resilience PASSED [ 93%]
tests/test_cu20_voice_rag_reports.py::test_cu20_exam_question_top_10_by_branch_3_months PASSED [100%]

======================= 15 passed in 46.40s =======================
```
* **Evaluación:** **100% ADECUADO.** Demostración automatizada, reproducible e irrefutable del cumplimiento técnico y metodológico.

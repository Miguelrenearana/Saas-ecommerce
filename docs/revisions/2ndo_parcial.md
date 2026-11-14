# Guía de defensa oral — Segundo parcial

Esta guía organiza una defensa clara y verificable de FashionStore. Está dirigida al equipo que presenta el proyecto y conecta cada pregunta del examen con la metodología ICONIX, los diagramas, las funciones implementadas y las pruebas documentadas. La guía distingue entre lo que describe el informe y lo que se comprobó directamente en el código; esa diferencia permite defender el trabajo con rigor sin afirmar capacidades que aún no están completas.

## Resumen ejecutivo para iniciar la defensa

> FashionStore evolucionó de una tienda electrónica a una plataforma SaaS multitenant para empresas de moda. La aplicación combina una PWA Angular y una aplicación móvil Flutter con un backend FastAPI y una base de datos PostgreSQL. El sistema separa los datos por empresa mediante `tenant_id`, organiza el backend en siete paquetes de dominio y cubre los procesos de catálogo, compras, reservas, POS, sincronización offline y analítica. Para explicar el diseño seguimos la trazabilidad de ICONIX: requisitos, casos de uso, análisis de robustez, secuencias, modelo de clases, implementación y pruebas.

El estado operativo más reciente declara **25 casos de uso**. Algunos documentos históricos todavía hablan de 28; para la presentación conviene usar el alcance vigente de 25 casos y mostrar la lista de [actores y casos de uso](../ACTORS_AND_USE_CASES.md) y el [checklist de fases](../ai/IMPLEMENTATION_PHASES.md).

## Antes de exponer: qué afirmar y qué matizar

Usa esta tabla para separar la evidencia documental del comportamiento comprobable:

| Tema | Evidencia actual | Cómo defenderlo con precisión |
|---|---|---|
| Persistencia de ventas POS offline en la PWA | `CajaPageComponent.submitSale()` guarda la venta mediante `IdbSalesService`; el servicio usa `localStorage` con la clave `fashionstore_pending_pos_sales`. | Di que la venta se conserva localmente en el navegador. No la llames IndexedDB: el nombre `IdbSalesService` y algunos documentos no coinciden con la implementación. |
| Descuento de stock durante el modo desconectado | `submitSale()` no actualiza un inventario local. El descuento central ocurre en `batch_sync_offline_sales()` durante la sincronización. | Di que el cliente conserva el ticket y que el servidor concilia el inventario al sincronizar. El descuento local que afirman algunos casos de prueba documentados aún no está respaldado por este flujo de frontend. |
| Inicio de sincronización | `CajaPageComponent.syncAllPending()` se invoca desde la interfaz cuando el usuario solicita sincronizar. | Describe la sincronización como una acción disponible al recuperar conectividad, no como una tarea automática al detectar el evento `online`. |
| Conflicto de stock y bandeja CU16 | `batch_sync_offline_sales()` registra `SyncOperation.status="EN_CONFLICTO"`, pero crea la venta con un `cash_reference` normal. `list_branch_sale_conflicts()` filtra ventas cuyo `cash_reference` comienza con `CONFLICT:` o es `EN_CONFLICTO`. | Explica que hay detección y funciones de resolución, pero la derivación automática de un conflicto nuevo desde CU15 a la bandeja CU16 necesita alinearse. No presentes el flujo completo como integrado de extremo a extremo. |
| Reporte de voz: 10 productos, últimos 3 meses, por sucursal | La consulta RAG actual devuelve como máximo 8 filas agrupadas por producto, talla y color; no aplica el período de tres meses ni agrupa por sucursal. | Expón CU20 como consulta ejecutiva sobre métricas reales con aislamiento por tenant. Aclara que la consulta específica del examen requiere ampliar la agregación. |
| Resultados de pruebas | [NEW_FORMAT_PRUEBAS.md](./NEW_FORMAT_PRUEBAS.md) reporta resultados “Satisfactorios”, pero varias tablas dejan vacío el campo de adjuntos. Los tests del backend contienen aserciones concretas. | Diferencia “resultado consignado en el informe” de “prueba ejecutada en esta revisión”. Para demostrar la ejecución, presenta la salida real del comando y los datos de prueba usados. |

---

## 1. Las cuatro etapas de ICONIX y la evolución SaaS multitenant

### Explicación oral sugerida

> ICONIX es un proceso iterativo e incremental que conecta los requisitos con el software mediante casos de uso. En FashionStore lo explicamos en cuatro etapas: análisis de requisitos; análisis y diseño preliminar; diseño; e implementación y pruebas. No producimos diagramas aislados: cada artefacto refina el anterior y deja una ruta para comprobar que el requisito terminó en código y en una prueba.
>
> La evolución del primer parcial al segundo no consistió en empezar otro producto. Se extendió la tienda hacia un SaaS: se incorporaron empresas contratantes, planes y cuotas, aislamiento por `tenant_id`, operación offline, sincronización idempotente, conciliación de ventas y analítica. La arquitectura actual agrupa la lógica en siete paquetes de dominio y mantiene los flujos funcionales anteriores que siguen formando parte del sistema.

### Cómo describir cada etapa con evidencia del proyecto

| Etapa ICONIX | Qué se hace | Evidencia en FashionStore |
|---|---|---|
| **1. Análisis de requisitos** | Se identifican actores, necesidades y reglas; se crea el modelo del dominio y se asignan requisitos a casos de uso. | [Actores y casos de uso](../ACTORS_AND_USE_CASES.md), [políticas de negocio](../BUSINESS_POLICIES.md), [fichas de casos de uso](./use_cases_details.md) y [diagrama general de clases](./diagrama_clases_bd_p2_EA.js). |
| **2. Análisis y diseño preliminar** | Se detallan los casos de uso con actores, precondiciones, flujo normal, alternativas y postcondiciones; luego se comprueba la interacción mediante robustez BCE. | Fichas en [use_cases_details.md](./use_cases_details.md) y diagramas de [robustez de CU13](../../docsUML/CUrobustez/CU13_comm_venta_pos_offline_EA.js). |
| **3. Diseño** | Se ordenan los mensajes y responsabilidades en diagramas de secuencia; se refinan las clases y sus relaciones. | [Secuencia de CU13](../../docsUML/CUSecuencia/CU13_secuencia_venta_pos_offline_EA.js) y el [diagrama general de clases](./diagrama_clases_bd_p2_EA.js). El diagrama general es el modelo de clases de datos del proyecto; no se está afirmando que haya un diagrama de clases por cada caso de uso. |
| **4. Implementación y pruebas** | Se implementan las responsabilidades asignadas, se persiste la información y se derivan pruebas de los flujos normales y alternativos. | Backend en `backend/app/packages/p0_...` a `p6_...`, PWA en `frontend/src/app`, aplicación móvil en `mobile/` y capítulo de [pruebas y resultados](./NEW_FORMAT_PRUEBAS.md). |

El [manual introductorio de ICONIX](./manual_introductorio_de_iconix.md) describe la relación entre las fichas, robustez, secuencia, clases, código y plan de pruebas. El diagrama general de clases declara 52 clases de dominio (47 tablas más cinco roles conceptuales) y relaciona elementos como `companies`, `branches`, `sales`, `sale_items` y `sync_operations`.

### Cómo demostrar que el producto evolucionó

1. **SaaS y aislamiento:** `p0_saas_plataforma` gestiona empresas y suscripciones; `p1_gestion_usuarios_acceso` gestiona usuarios, roles y sucursales. Las consultas y peticiones deben operar dentro del `tenant_id` autorizado.
2. **Operación distribuida:** el catálogo offline y la caja desconectada mantienen operaciones en el cliente y las concilian con el backend al volver la red.
3. **Reglas comerciales nuevas:** CU17 y CU18 gestionan cambios por diferencia de precio y devoluciones con retención.
4. **Analítica:** `p6_inteligencia_analitica` expone reportes y consultas ejecutivas, además de funcionalidades de aprendizaje automático.
5. **Trazabilidad:** los cambios se organizan por CU y paquete, y se documentan en fichas, diagramas, servicios y pruebas.

**Respuesta si preguntan por el diagrama de clases:** “Nuestro diagrama de clases es el general de dominio/base de datos que está en el informe. En la defensa de CU13 lo uso para señalar las clases persistentes que participan, como `Sale`, `SaleItem`, `Inventory` y `SyncOperation`; la secuencia muestra el comportamiento de ese caso de uso”.

---

## 2. Relación entre casos de uso, robustez, secuencia y clases

### Explicación oral sugerida

> El caso de uso define qué resultado busca el actor y bajo qué condiciones. La ficha describe el flujo normal y sus alternativas. El diagrama de robustez asigna ese flujo a fronteras, controladores y entidades; el diagrama de secuencia ordena temporalmente los mensajes entre esos participantes. El diagrama general de clases muestra la estructura estática de las entidades y asociaciones que soportan los mensajes. Finalmente, el código implementa esas responsabilidades y las pruebas comprueban resultados observables.
>
> Para CU13, el cajero inicia la venta en la frontera `CajaPageComponent`. El componente valida el monto y el modo de conexión, construye un ticket con `client_sale_id` y delega la persistencia a `IdbSalesService.savePending()`. Al sincronizar, `syncAllPending()` envía las ventas al endpoint de lote. El backend procesa la operación en `batch_sync_offline_sales()` y persiste las entidades centrales de venta e inventario.

### Relación de artefactos en una sola cadena

```text
Requisito de continuidad de caja
  -> CU13: venta POS desconectada
  -> Ficha: actor, precondición, flujo y alternativas
  -> Robustez: Cajero -> CajaPageComponent -> IdbSalesService / SalesService -> entidades
  -> Secuencia: orden de guardado local y posterior sincronización
  -> Clases: Sale, SaleItem, Inventory, SyncOperation y relaciones
  -> Código: submitSale(), savePending(), syncAllPending(), batch_sync_offline_sales()
  -> Pruebas: efectivo, UUID, idempotencia, stock e aislamiento
```

### Cómo defender el diagrama de robustez de CU13

El archivo de [robustez CU13](../../docsUML/CUrobustez/CU13_comm_venta_pos_offline_EA.js) declara estos participantes:

| Tipo BCE | Elemento del diagrama | Componente/código correspondiente |
|---|---|---|
| Actor | `Cajero` | Usuario que opera el POS. |
| Boundary | `CajaPageComponent` | [`caja-page.component.ts`](../../frontend/src/app/features/cajero/pages/caja-page.component.ts): presenta la caja y coordina `submitSale()` y `syncAllPending()`. |
| Boundary | `TicketContingenciaModal` | Modal de comprobante de contingencia presentado por la interfaz de caja. |
| Control local (representación del diagrama) | `IdbSalesService` | [`idb-sales.service.ts`](../../frontend/src/app/core/offline/idb-sales.service.ts): `savePending()`, `getPendingOnly()` y `markAsSynced()`. Aunque el nombre contiene “Idb”, en el flujo actual usa `localStorage`. |
| Control central (representación del diagrama) | `SalesService` | Servicio de ventas del backend; para el lote, la función concreta es `batch_sync_offline_sales()` en [`sales_service.py`](../../backend/app/packages/p5_gestion_ventas_pos/services/sales_service.py). |
| Entity | `PendingOfflineSale` | Estructura TypeScript de una venta pendiente definida en `idb-sales.service.ts`. |
| Entity | `Sale`, `SaleItem`, `Inventory` | Entidades persistidas y consultadas por el servicio backend. La estructura general se presenta en el [diagrama de clases](./diagrama_clases_bd_p2_EA.js). |

**Regla de modelado:** el actor expresa una intención a una frontera; las decisiones, validaciones y flujos alternativos corresponden al controlador. Para esta defensa, señala que el script del diagrama usa nombres conceptuales BCE y que algunos mensajes son etiquetas de diseño, no nombres literales de funciones TypeScript. Por ejemplo, el mensaje del diagrama `syncPendingSales()` corresponde actualmente a `CajaPageComponent.syncAllPending()`.

### Cómo defender la secuencia de CU13

La [secuencia CU13](../../docsUML/CUSecuencia/CU13_secuencia_venta_pos_offline_EA.js) separa dos momentos:

1. **Venta sin conexión:** el cajero interactúa con `CajaPageComponent`; la aplicación valida `isOfflineEffective()`, construye el identificador, crea un `PendingOfflineSale` y lo guarda mediante `IdbSalesService.savePending()`. Después se muestra el comprobante.
2. **Sincronización posterior:** cuando hay conectividad y el cajero solicita sincronizar, `syncAllPending()` construye el lote y llama a `salesApi.batchSyncSales()`. El backend busca los identificadores previamente procesados, aplica las nuevas ventas y devuelve UUID procesados, duplicados y conflictos. El frontend marca los confirmados con `markAsSynced()`.

La secuencia documenta el flujo que se quiere representar; al exponer el comportamiento real, matiza que la sincronización en la pantalla POS es manual y que el cliente no descuenta localmente el inventario actual.

---

## 3. Caso de uso elegido: CU13, registrar una venta offline

### Cómo justificar a los actores

- **Actor principal — Cajero:** inicia el cobro y confirma la venta física en la sucursal.
- **Actor secundario — POS local:** permite consultar lo que está disponible en el dispositivo y conservar la operación cuando no se puede contactar al servidor.
- **Actor secundario — Backend API:** recibe el lote al restablecerse la conexión, verifica tenant, UUID e inventario y consolida la venta.
- **Actor secundario — Encargado de sucursal:** participa posteriormente si se debe resolver una discrepancia de inventario.

La selección se basa en responsabilidades observables: inicia el objetivo de negocio, provee un servicio externo o responde a una contingencia. El cliente que compra es parte del contexto de la venta, pero el actor que opera CU13 en el software es el cajero.

### Ficha resumida para explicar

| Campo | CU13 |
|---|---|
| **Objetivo** | Permitir que la caja registre una venta presencial durante una caída de Internet. |
| **Actor principal** | Cajero de sucursal. |
| **Precondiciones** | La sucursal y el cajero están identificados; existe catálogo utilizable en el terminal; el equipo detecta que no hay conexión; el cajero tiene productos seleccionados. |
| **Flujo normal** | Seleccionar prendas; calcular total; permitir efectivo como forma de pago; verificar que el efectivo cubra el total; crear UUID; guardar la venta pendiente localmente; mostrar ticket; más tarde, enviar el lote y marcar la venta confirmada. |
| **Alternativas** | Intento de pago electrónico: no está disponible en contingencia; efectivo insuficiente: no se confirma; sin red al intentar sincronizar: se conserva la operación para reintento; UUID ya recibido: no se vuelve a crear ni a descontar el stock. |
| **Postcondición** | En la etapa offline existe un ticket local identificable. Tras la sincronización exitosa, el servidor conserva la venta central y la operación queda marcada como sincronizada en el cliente. |

### Guion oral

> Elegimos CU13 porque representa una necesidad operativa concreta: una tienda no debería detener la caja por una interrupción de Internet. El cajero es el actor principal porque controla el cobro y confirma la entrega física. Exigimos pago en efectivo porque sin conexión no podemos confirmar con seguridad una pasarela electrónica. Como precondición, el terminal debe disponer de los datos de venta necesarios y estar asociado a una sucursal. El flujo normal termina primero con la venta pendiente en el dispositivo y, más tarde, con la conciliación central. Si el dinero no cubre el total, si se intenta pagar electrónicamente o si falla la red durante el envío, no se debe perder el ticket. La postcondición final de sincronización es que el backend tenga una sola venta con su identificador de cliente.

La ficha detallada del CU13 está en [use_cases_details.md](./use_cases_details.md); la política de efectivo de contingencia está en [BUSINESS_POLICIES.md](../BUSINESS_POLICIES.md).

---

## 4. Recorrido de una venta cuando no hay Internet

### Qué datos se guardan en la PWA

En [`caja-page.component.ts`](../../frontend/src/app/features/cajero/pages/caja-page.component.ts), `CajaPageComponent.submitSale()`:

1. Comprueba que se haya identificado una sucursal y que haya artículos seleccionados.
2. Comprueba que el dinero recibido no sea menor al total.
3. Si `isOfflineEffective()` indica desconexión, genera `crypto.randomUUID()`.
4. Construye una venta con `client_sale_id`, `sale_code`, sucursal, cajero, método de pago `cash`, efectivo recibido, vuelto, subtotal, descuento, total, moneda, fecha e ítems.
5. Llama a `this.idbSales.savePending(pendingSale)`.
6. Actualiza la interfaz y muestra el modal de comprobante offline.

El tipo `PendingOfflineSale` en [`idb-sales.service.ts`](../../frontend/src/app/core/offline/idb-sales.service.ts) incluye también los detalles por prenda: `variant_id`, nombre, SKU, talla, color, precio unitario, cantidad y total de línea. La persistencia real usa la clave de `localStorage` `fashionstore_pending_pos_sales`. El tipo marca la venta `synced: false` y el servicio ofrece operaciones para leer pendientes, incrementar reintentos, marcar errores, marcar sincronizados y depurar los sincronizados.

### Qué ocurre al recuperar conexión

1. El cajero solicita sincronización desde la caja. `CajaPageComponent.syncAllPending()` evita el envío si el terminal sigue offline y si no hay pendientes.
2. El componente transforma las ventas pendientes en `BatchSyncRequest`, con pago `cash`, indicador offline, UUID y productos, y llama a `salesApi.batchSyncSales()`.
3. La ruta backend `/api/sales/offline/batch-sync` llega a `batch_sync_offline_sales()` en [`sales_service.py`](../../backend/app/packages/p5_gestion_ventas_pos/services/sales_service.py).
4. El servicio verifica que la sucursal pertenece al `tenant_id`, consulta `sync_operations` y `Sale.client_sale_id` para reconocer reintentos y descarta IDs ya aplicados.
5. Para una operación nueva, valida efectivo, encuentra variantes pertenecientes al tenant y obtiene el inventario con bloqueo mediante `_get_inventory_for_update()`.
6. Persiste la venta, sus ítems, el movimiento de inventario y el registro en `SyncOperation`, y ejecuta `db.commit()`.
7. El frontend interpreta la respuesta: marca los UUID confirmados con `IdbSalesService.markAsSynced()` y deja un resumen de aplicadas, duplicadas y conflictos.

### Qué enfatizar y qué no afirmar

- **Sí:** el UUID local se usa como identidad idempotente; un reenvío ya procesado debe resultar en duplicado ignorado.
- **Sí:** el backend comprueba la sucursal y el tenant, y el inventario se modifica en la sincronización central.
- **No:** no afirmes que la PWA ya usa IndexedDB para la cola de ventas. El código de ventas usa `localStorage`.
- **No:** no afirmes que se descuenta stock en el almacén local durante `submitSale()`. El flujo de la PWA no hace esa operación.
- **No:** no digas que un evento de reconexión envía automáticamente todas las ventas. La implementación actual expone `syncAllPending()` desde la caja y comprueba la conectividad al invocarlo.

---

## 5. Dos dispositivos venden la última unidad offline

### Explicación técnica

Cada dispositivo trabaja con su propio estado local y no puede reservar de forma central la última unidad mientras está desconectado. Por eso ambos podrían aceptar la venta física. Al sincronizar:

1. La primera operación recibida encuentra stock central suficiente, registra la venta y reduce el inventario.
2. La siguiente operación obtiene el inventario central bajo bloqueo. Si la cantidad disponible es inferior a la vendida, `batch_sync_offline_sales()` marca `is_conflict = True`.
3. El código actual registra un `SyncOperation` con estado `EN_CONFLICTO` y agrega el UUID a la respuesta de conflictos. **Aun así crea la venta y resta la cantidad, por lo que el stock central puede quedar negativo.** Esto refleja la decisión de conciliar una venta que pudo haberse cobrado y entregado físicamente.
4. El encargado debería revisar el caso y elegir la resolución: autorizar stock negativo/reposición, sustituir por una variante disponible o emitir una nota de crédito.

En [`sale_conflict_service.py`](../../backend/app/packages/p5_gestion_ventas_pos/services/sale_conflict_service.py), `resolve_sale_conflict()` valida una justificación de al menos cinco caracteres y ofrece las tres estrategias. La lista se construye en `list_branch_sale_conflicts()`. En frontend, [`sale-conflicts-page.component.ts`](../../frontend/src/app/features/encargado/pages/sale-conflicts-page.component.ts) implementa `loadConflicts()` y `submitResolution()`.

### Limitación de integración que conviene exponer

El servicio de sincronización guarda el conflicto en `SyncOperation.status`, pero crea `Sale.cash_reference` con un texto como `Offline Batch Sync - Ticket ...`. En cambio, `list_branch_sale_conflicts()` busca ventas cuyo `cash_reference` empiece por `CONFLICT:` o sea exactamente `EN_CONFLICTO`. Por ello, **la ruta desde un conflicto recién detectado por CU15 hasta su aparición en la bandeja CU16 no queda alineada en el código actual**. La suite CU16 prepara ventas con `cash_reference="CONFLICT:..."` y prueba su consulta y resolución; no demuestra por sí sola el flujo integral desde el endpoint batch.

### Guion oral

> El conflicto aparece por consistencia eventual: cada caja offline puede aceptar una transacción con su conocimiento local, pero el inventario central decide cuál operación encuentra disponibilidad al sincronizar. Si la segunda llega sin stock, el backend registra la excepción con el UUID y conserva la trazabilidad. Como la prenda pudo entregarse, no borramos silenciosamente la operación: el encargado decide entre reponer con stock negativo autorizado, entregar un sustituto aceptado por el cliente o emitir una nota de crédito. Tenemos una brecha de integración entre el registro de conflicto del batch y el filtro de la bandeja, que estamos identificando como mejora: ambos deben compartir una fuente/estado de conflicto y probarse en una única prueba end-to-end.

Pruebas que respaldan partes del flujo: [idempotencia CU15](../../backend/tests/test_cu15_batch_sync_idempotency.py), [resolución CU16](../../backend/tests/test_cu16_resolve_offline_sale_conflicts.py) y escenarios documentados en [NEW_FORMAT_PRUEBAS.md](./NEW_FORMAT_PRUEBAS.md).

---

## 6. Consulta por voz: “10 productos más vendidos en los últimos 3 meses por sucursal”

### Qué está implementado

1. El componente [`voice-assistant-modal.component.ts`](../../frontend/src/app/features/admin/components/voice-assistant-modal.component.ts) comprueba las capacidades del navegador para reconocimiento de voz y voz sintetizada. Configura el idioma `es-BO`, obtiene una transcripción y la envía como texto.
2. [`reports-api.service.ts`](../../frontend/src/app/features/shared/services/reports-api.service.ts) consume la API de reportes de voz.
3. La ruta `POST /api/reports/voice-query` está implementada en [`voice_report_routes.py`](../../backend/app/packages/p6_inteligencia_analitica/routes/voice_report_routes.py). `process_voice_query_endpoint()` valida el rol y resuelve el tenant desde el JWT (o el encabezado permitido para el superadmin).
4. `process_voice_query()` en [`gemini_rag_service.py`](../../backend/app/packages/p6_inteligencia_analitica/services/gemini_rag_service.py) comprueba acceso de IA según el plan, obtiene contexto y llama a Gemini; si Gemini falla, usa `_generate_heuristic_fallback()`.
5. `build_tenant_rag_context()` consulta ventas completadas y agrega métricas reales, con filtro por `tenant_id` y opcionalmente por una sucursal.

### Brecha para la consulta exacta del examen

La función `build_tenant_rag_context()` actualmente:

- Agrupa los productos por nombre, talla y color.
- Ordena por unidades vendidas y limita la consulta a **8** resultados.
- No filtra las ventas a los **últimos tres meses**.
- No agrupa los resultados de productos **por sucursal**; si se envía `branch_id`, restringe a una sucursal.

Por lo tanto, la pregunta exacta “los 10 productos más vendidos durante los últimos 3 meses agrupados por sucursal” no está implementada como una agregación verificable en este RAG. Gemini recibe contexto estructurado limitado y la pregunta; no debe afirmarse que el modelo ejecuta SQL ni que ya interpreta esos filtros con exactitud. La consulta puede producir una respuesta conversacional, pero no garantiza el resultado analítico requerido.

### Guion oral recomendado

> El usuario habla y el navegador convierte su voz a texto. La PWA envía esa pregunta a `/api/reports/voice-query`. El backend obtiene el tenant autenticado, consulta PostgreSQL con filtros de tenant y prepara un contexto de ventas y productos. Gemini redacta una explicación a partir de ese contexto; si el proveedor no está disponible, se utiliza una respuesta heurística. Para la pregunta del examen, la ruta RAG demuestra consulta con lenguaje natural sobre datos reales, pero el agregado actual todavía no satisface el top 10 de tres meses por sucursal. Para cumplirlo por completo debemos extraer esos parámetros, ejecutar una agregación SQL con el intervalo y agrupación solicitados, y pasar ese resultado comprobable a Gemini.

Prueba disponible: [`test_cu20_voice_rag_reports.py`](../../backend/tests/test_cu20_voice_rag_reports.py) prueba capacidades, consulta exitosa, bloqueo por plan básico y fallback heurístico. El caso exitoso actual pregunta por productos vendidos y facturación, no por el top 10 por sucursal en tres meses.

---

## 7. Requisitos funcionales/no funcionales y tres pruebas críticas

### Cómo explicar la estrategia de pruebas

> Derivamos las pruebas de los flujos normales, alternativos y reglas del caso de uso. Para cada prueba definimos precondiciones, datos, acción, resultado esperado y resultado observado. Para evidenciar un requisito no basta con una captura de pantalla: mostramos también el test automatizado o la respuesta HTTP y el estado persistido que demuestra el resultado.

La matriz de [NEW_FORMAT_PRUEBAS.md](./NEW_FORMAT_PRUEBAS.md) cubre los CUs y describe procedimientos. Las pruebas backend relevantes se encuentran en `backend/tests/`. El informe lista “Satisfactorio” para escenarios seleccionados, pero los campos de adjuntos visibles están vacíos. Presenta la salida de ejecución, capturas o consultas de base de datos si se requieren resultados reproducibles.

### Prueba crítica 1 — Venta de contado offline (CU13)

| Elemento | Procedimiento/evidencia |
|---|---|
| **Requisito** | Mantener la operación de caja en desconexión, forzar efectivo e identificar cada venta para sincronización. |
| **Datos** | Tenant Boutique Elegance, sucursal activa, cajero, variante existente con inventario inicial 20 y venta de 2 unidades; el test genera UUID mediante `uuid.uuid4()`. |
| **Acción** | Crear una venta offline con `payment_method=cash`, `is_offline=True`, `client_sale_id` e ítem; comprobar por separado el rechazo de Stripe. |
| **Esperado** | La venta tiene UUID, método efectivo y estado esperado; el test de rechazo lanza un error para pago no efectivo. La prueba de duplicado asegura que el segundo envío no crea otra venta ni reduce stock otra vez. |
| **Evidencia** | [`test_cu13_offline_pos_sales.py`](../../backend/tests/test_cu13_offline_pos_sales.py): `test_01_create_offline_sale_cash_success()`, `test_02_offline_sale_rejects_non_cash_payment()` y `test_03_idempotent_duplicate_client_sale_id()`. El flujo visual local también se contrasta con `CajaPageComponent.submitSale()`. |
| **Resultado reportado** | El capítulo [NEW_FORMAT_PRUEBAS.md](./NEW_FORMAT_PRUEBAS.md), sección CU13, consigna “Satisfactorio”. No se ejecutó esa suite durante la preparación de esta guía; no afirmes que se ejecutó ahora. |

**Matiz metodológico:** estas pruebas llaman al servicio backend `create_sale()`; no sustituyen una prueba de navegador que demuestre que `submitSale()` guarda realmente el ticket en `localStorage` sin red. Para cerrar esa evidencia se recomienda agregar una prueba frontend del flujo local.

### Prueba crítica 2 — Lote idempotente al reintentar (CU15)

| Elemento | Procedimiento/evidencia |
|---|---|
| **Requisito** | Si se pierde la respuesta de un envío y se reintenta el mismo UUID, no debe duplicarse la venta ni descontarse inventario dos veces. |
| **Datos** | Tenant Elegance, una sucursal, variante con stock 100 y dos ventas UUID distintas. El test sincroniza primero ambas ventas; luego reenvía exactamente las mismas. |
| **Acción** | Comparar cantidad de ventas e inventario antes y después del segundo batch. |
| **Esperado** | En el primer lote, `applied=2`; en el duplicado, `applied=0`, `duplicates_ignored=2`, número de ventas sin cambio y cantidad de inventario sin cambio. |
| **Evidencia** | [`test_cu15_batch_sync_idempotency.py`](../../backend/tests/test_cu15_batch_sync_idempotency.py): `test_batch_sync_happy_path()` y `test_batch_sync_idempotency_duplicate_resend()`. La lógica está en `batch_sync_offline_sales()`. |
| **Resultado reportado** | El capítulo de pruebas reporta el lote como “Satisfactorio”. Para el examen, muestra las aserciones y, si está disponible, la salida de `pytest`. |

### Prueba crítica 3 — Resolver una venta en conflicto (CU16)

| Elemento | Procedimiento/evidencia |
|---|---|
| **Requisito** | Permitir conciliación auditada cuando la operación offline coincide con inventario central agotado. |
| **Datos** | El test crea un tenant, sucursal, encargado, cajero, prenda y tres variantes: una con stock 0, sustituta con stock 3 y otra agotada; prepara ventas marcadas `CONFLICT:`. |
| **Acción** | Consultar la bandeja y probar `negative_stock`, sustitución, nota de crédito, sustitución sin stock, nota insuficiente y aislamiento entre tenants. |
| **Esperado** | La consulta devuelve el ticket; cada vía modifica el estado/stock previsto; una nota menor de 5 caracteres es rechazada; otro tenant no puede leer/resolver la venta. |
| **Evidencia** | [`test_cu16_resolve_offline_sale_conflicts.py`](../../backend/tests/test_cu16_resolve_offline_sale_conflicts.py): `test_01_list_branch_sale_conflicts()` a `test_07_multitenant_isolation()`. |
| **Límite de lo que prueba** | El test prepara la venta como `CONFLICT:` antes de consultar CU16. No prueba que la venta conflictiva producida por `batch_sync_offline_sales()` llegue automáticamente a esa bandeja. Esa integración debe añadirse para demostrar el escenario de dos dispositivos de punta a punta. |

### Aspectos no funcionales que conviene mencionar

- **Aislamiento:** validar que las consultas usen el tenant del JWT y que las pruebas de aislamiento intenten acceder con un tenant diferente.
- **Integridad:** demostrar que un UUID repetido no causa duplicación y que la modificación de inventario ocurre dentro del procesamiento central.
- **Resiliencia:** ante error de red, conservar el ticket local y permitir reintentar sin pérdida.
- **Auditabilidad:** conservar UUID, estado y datos de sincronización; exigir nota al resolver conflicto.
- **Usabilidad:** mostrar estado de conexión, ventas pendientes, resultado del batch y mensaje entendible para el cajero.

No presentes estos atributos como demostrados solo por mencionarlos en la arquitectura: vincula cada uno con una prueba concreta, una consulta persistida o una evidencia de ejecución.

---

## Respuestas rápidas para preguntas de seguimiento

### “¿Por qué no se pierde una venta si se cae la conexión al sincronizar?”

Porque el cliente conserva la operación y su UUID. Si el servidor la alcanzó a procesar pero no llegó la respuesta, el reintento encuentra ese identificador y la trata como duplicado; el frontend la marca sincronizada cuando recibe el acuse.

### “¿El UUID reemplaza la transacción de base de datos?”

No. El UUID permite reconocer la misma operación en reintentos. La transacción central protege la escritura de la venta, los ítems, el inventario y el registro de sincronización.

### “¿Qué valida el aislamiento multitenant?”

El token identifica el tenant y los servicios filtran sucursales, ventas o productos por ese tenant. Para demostrarlo, señala los filtros en el servicio de dominio y las pruebas donde otro tenant intenta acceder a la entidad.

### “¿El diagrama es una foto literal de las clases Angular?”

No. Los diagramas ICONIX modelan responsabilidades y estructura conceptual. En la defensa se debe mapear cada participante a su componente o función real y reconocer cuando un mensaje descriptivo del diagrama tiene otro nombre en el código.

---

## Mejoras priorizadas después de la defensa

1. **Integrar conflictos CU15 → CU16:** al registrar conflicto, persistir un estado/fuente que `list_branch_sale_conflicts()` consulte directamente; agregar una prueba end-to-end que sincronice una venta sin stock y la resuelva desde la bandeja.
2. **Alinear persistencia y documentación offline:** decidir si la cola de ventas debe migrar a IndexedDB o si `localStorage` es la decisión actual; actualizar los documentos y las pruebas en consecuencia.
3. **Definir el inventario local:** implementar el descuento de la caché local de forma transaccional si la regla exige evitar una segunda venta desde el mismo terminal, o actualizar la ficha/diagrama si esa regla ya no forma parte del comportamiento.
4. **Automatizar o especificar explícitamente la sincronización:** si debe dispararse al reconectar, implementar el listener de conectividad y probarlo; de lo contrario, documentar que el cajero inicia el envío desde la bandeja.
5. **Completar la consulta CU20 del examen:** aceptar o identificar periodo y agrupación, consultar top 10 dentro de los últimos tres meses por sucursal usando SQL filtrado por tenant y fecha, y verificarlo con datos de control conocidos.
6. **Mejorar evidencia de pruebas:** ejecutar suites sobre una base de datos de pruebas aislada, guardar la salida reproducible y adjuntar capturas o resultados de consulta. Los tests actuales usan `SessionLocal` y algunos reinician cantidades de inventario; no se deben ejecutar contra una base de datos compartida o de producción.

## Checklist para el día de la exposición

- [ ] Presentar el alcance vigente de 25 casos de uso y explicar la evolución SaaS, no describirlo como un sistema nuevo sin relación con el primer parcial.
- [ ] Mostrar la ficha CU13 y relacionar sus flujos normal/alternativos con los diagramas.
- [ ] En robustez, señalar actor, fronteras, controladores y entidades, y mapearlos a `submitSale()`, `savePending()`, `syncAllPending()` y `batch_sync_offline_sales()`.
- [ ] Aclarar que el diagrama general de clases es el modelo de datos global del proyecto.
- [ ] Explicar que el POS web guarda la venta offline en `localStorage` y que el backend descuenta el inventario al sincronizar.
- [ ] Describir la brecha de integración entre el conflicto de `SyncOperation` y el filtro de la bandeja CU16 como mejora pendiente, si preguntan por el caso de dos dispositivos.
- [ ] En la pregunta de voz, distinguir las capacidades RAG implementadas de la agregación concreta top 10 / tres meses / por sucursal que falta.
- [ ] Mostrar resultados de pruebas ejecutadas de forma reproducible; no presentar como recién ejecutadas las cifras que solo aparecen en el informe.
- [ ] Ejecutar pruebas únicamente con configuración y base de datos aisladas de prueba.

## Referencias principales

- [Actores y casos de uso](../ACTORS_AND_USE_CASES.md)
- [Políticas de negocio](../BUSINESS_POLICIES.md)
- [Protocolo offline y sincronización](../OFFLINE_AND_SYNC.md)
- [Arquitectura técnica](../ARCHITECTURE.md)
- [Manual introductorio de ICONIX](./manual_introductorio_de_iconix.md)
- [Fichas de casos de uso](./use_cases_details.md)
- [Diagrama general de clases](./diagrama_clases_bd_p2_EA.js)
- [Diagrama de robustez CU13](../../docsUML/CUrobustez/CU13_comm_venta_pos_offline_EA.js)
- [Diagrama de secuencia CU13](../../docsUML/CUSecuencia/CU13_secuencia_venta_pos_offline_EA.js)
- [Pruebas y resultados](./NEW_FORMAT_PRUEBAS.md)

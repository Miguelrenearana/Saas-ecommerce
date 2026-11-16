# Sesión: 2026-11-14 - Arquitectura de Modales Responsivos y Protección de Descarte (Frontend)

## 1. Contexto y Objetivos
- **Problema Reportado:** 
  1. En la interfaz web/PWA de FashionStore (Angular 21 + TailwindCSS + Spartan UI), los modales se renderizaban dentro de contenedores internos (`<main>`, `hlmSidebarInset`) sujetos a *CSS containment* y transformaciones, generando un nuevo *stacking context*. Como resultado, el fondo oscuro (`backdrop`) y el modal quedaban atrapados dentro del área de la sección, dejando visible el sidebar lateral y el header, y quedando sujetos al scroll vertical de la página.
  2. Al desplegar modales con formularios extensos o edición de datos, cualquier clic accidental en el backdrop o en el botón de cerrar (`X`) provocaba el cierre intempestivo del modal, perdiendo la información ingresada por el usuario sin confirmación previa.
- **Requerimiento:**
  - Diseñar e implementar dos plantillas reutilizables para el proyecto inspiradas en la arquitectura de `ModalLectura` y `ModalFormulario`:
    - **Modal de Lectura (`ModalLecturaComponent`):** Para consultas, detalles o asistentes donde no se mutan datos; permite cierre rápido por clic en backdrop o tecla `Escape`.
    - **Modal de Escritura / Formulario (`ModalFormularioComponent`):** Para ingreso o edición de datos; backdrop estático que bloquea clics externos con micro-sacudida visual (*shake effect*) y diálogo de confirmación de descarte (`ConfirmarDescarteDialogComponent`) si el usuario intenta salir teniendo datos modificados (`tieneCambios = true`).
  - Solucionar definitivamente el confinamiento en el scrollbar de la sección mediante escape al `document.body` (teletransportación del nodo).
  - Conservar 100% el diseño visual, paletas de colores, tarjetas internas y contratos de negocio de los modales existentes del proyecto.

---

## 2. Componentes Creados (`frontend/src/app/features/shared/components/modal/`)

1. **[`modal-base.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/shared/components/modal/modal-base.component.ts):**
   - **Escape del Stacking Context:** Implementa inyección de `Renderer2` y `ElementRef` para mover el elemento nativo del modal al `document.body` durante el ciclo `ngOnInit()` (`this.renderer.appendChild(document.body, this.elementRef.nativeElement)`), y lo remueve en `ngOnDestroy()`. Con esto, el modal cubre el 100% de la pantalla (`z-[60]`) por encima de cualquier sidebar o header.
   - **Bloqueo de Scroll Global:** Agrega automáticamente `overflow-hidden` al `document.body` mientras está abierto.
   - **Animaciones Fluidas:** Transición de entrada/salida controlada con estados reactivos (`abiertoReal`, `animando`), con micro-sacudida visual en el contenedor ante intentos de clic en el backdrop estático (`sacudiendo = signal(true)` con clase CSS `scale-[1.015] ring-4 ring-primary/30 duration-150`).
   - **Proyección de Contenido Flexible:** Soporte de directivas/slots `[modal-header-icon]`, `[modal-header-custom]`, cuerpo genérico y `[modal-footer]`.

2. **[`confirmar-descarte-dialog.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/shared/components/modal/confirmar-descarte-dialog.component.ts):**
   - Diálogo modal de alta prioridad (`z-[70]`, `role="alertdialog"`) montado en `document.body`.
   - Presenta ícono de advertencia ámbar, advertencia de cambios sin guardar y botones "Continuar editando" (foco por defecto) y "Descartar y salir".

3. **[`modal-formulario.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/shared/components/modal/modal-formulario.component.ts):**
   - Envolvente especializada para formularios con `backdropEstatico = true`.
   - Recibe la propiedad `[tieneCambios]="boolean"` y gestiona internamente la intercepción del cierre. Si hay cambios pendientes, suspende el cierre y despliega `app-confirmar-descarte-dialog`. Si no hay cambios, emite `cerrar` directamente.

4. **[`modal-lectura.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/shared/components/modal/modal-lectura.component.ts):**
   - Envolvente ligera para visualización de detalles, términos, auditorías y asistentes.
   - Configura `backdropEstatico = false`, permitiendo cierre fluido al pulsar el backdrop o presionar `Escape`.

5. **[`index.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/shared/components/modal/index.ts):**
   - Barrel export para simplificar importaciones en cualquier módulo o componente standalone.

---

## 3. Modales Migrados y Verificados

* **[`subscription-modal.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/superadmin/components/subscription-modal.component.ts):**
  - Migrado a `app-modal-formulario`.
  - Evalúa reactivamente cambios en fecha de caducidad, estado o plan seleccionado (`tieneCambios()`).
  - Mantiene intacta la simulación de suscripciones y vigencias (Punto 9.5 del examen de Sistemas 2).
* **[`tenant-form-modal.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/superadmin/components/tenant-form-modal.component.ts):**
  - Migrado a `app-modal-formulario`.
  - Vinculado a `[tieneCambios]="tenantForm.dirty"` con método `solicitarCierre()`.
* **[`plan-form-modal.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/superadmin/components/plan-form-modal.component.ts):**
  - Migrado a `app-modal-formulario`.
  - Compara las propiedades del formulario contra el estado inicial para activar `tieneCambios()`.
* **[`voice-assistant-modal.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/admin/components/voice-assistant-modal.component.ts) & [`.html`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/admin/components/voice-assistant-modal.component.html):**
  - Migrado a `app-modal-lectura`.
  - Preserva el tema oscuro con fondo `bg-slate-900 border-slate-800`, botón de micrófono flotante y locución de síntesis de voz con Gemini 2.5 Flash.
* **[`policies-modal.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/shared/components/policies-modal.component.ts):**
  - Migrado a `app-modal-lectura`.
  - Preserva la navegación por pestañas (*Políticas Comerciales de Tienda* vs *Términos SaaS FashionStore*), la lectura de políticas de cambio de prenda por talla y devoluciones de la plataforma.

---

## 4. Pruebas y Verificaciones
- **Chequeo de Tipos y Compilación de Plantillas de Angular (`ngc` / AOT):**
  - Se subsanó el tag remanente de cierre `</div>` en [`voice-assistant-modal.component.html`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/admin/components/voice-assistant-modal.component.html).
  - Se extendió `AnchoModal` para soportar `'2xl'` y se mapeó a `max-w-5xl` en [`modal-base.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/shared/components/modal/modal-base.component.ts).
  - Se ajustó `ancho="xl"` en [`policies-modal.component.ts`](file:///c:/Users/PERSONAL/ecommerce-SI2/frontend/src/app/features/shared/components/policies-modal.component.ts) alineándose al ancho original (`max-w-3xl`).
  - Ejecutado `cd frontend; npx ngc -p tsconfig.app.json --noEmit` completando con código de salida 0 (0 errores en plantillas ni tipos).

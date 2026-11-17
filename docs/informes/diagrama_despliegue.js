/* =================================================================================
 * PROYECTO: FashionStore - Plataforma E-Commerce SaaS Multitenant
 * DIAGRAMA: Diagrama de Despliegue Físico y Cloud (Deployment Diagram UML 2.5+)
 * CAPÍTULO: Capítulo IV. Desarrollo e Implementación - Arquitectura de Despliegue
 *
 * DESCRIPCIÓN DE NODOS Y TOPOLOGÍA FÍSICA:
 *   1. DISPOSITIVOS CLIENTES Y ADMINISTRATIVOS (Color Melocotón Pastel):
 *      - Dispositivo Sucursal / Admin (PC Escritorio / Terminal POS): Admin Dashboard SPA (Angular).
 *      - Dispositivo Cliente (PC / Laptop / Smartphone Android): Web Client App (Angular) y Mobile App (Flutter).
 *
 *   2. INFRAESTRUCTURA DE SERVIDORES CLOUD (Color Azul Cielo Pastel):
 *      - Servidor Web Frontend (Vercel Cloud Platform): Vercel Edge CDN, Web Bundle Angular 21 y decart-try-on.html.
 *      - Servidor Backend (Render Cloud Platform - Docker + FastAPI): Python 3.12, REST API y background workers.
 *      - Servidor Base de Datos (Neon Cloud Serverless PostgreSQL 16): Motor DBMS y esquema multi-tenant de 58 tablas.
 *      - Red Internet (WAN / Red Pública Segura): Tránsito cifrado con TLS 1.3 / HTTPS.
 *
 *   3. SERVICIOS EXTERNOS EN LA NUBE (Color Lavanda / Púrpura Pastel):
 *      - Google Cloud - Gemini AI (Asistente inteligente e IA / google-genai).
 *      - Hugging Face Space / Lucy VTON (Probador virtual por foto / gradio_client).
 *      - Mailtrap (Envío transaccional de correos y recuperación de contraseña).
 *      - Pasarela de Pago (Stripe Payments REST API).
 *      - Firebase Cloud Messaging (Notificaciones push web y móvil).
 *      - Cloudinary Media Cloud (Gestión y CDN de multimedia).
 *      - Decart AI (Probador virtual en tiempo real / WebRTC).
 *
 * ENTORNO: Enterprise Architect 15.0+ / 16.0+
 * LENGUAJE: JScript (Motor nativo WSH / JScript en Enterprise Architect)
 * ================================================================================= */

var DEFAULT_PACKAGE_NAME = "CUdiagrams";
var DIAGRAM_NAME = "Diseño Físico — Diagrama de Despliegue";

// ---------------------------------------------------------------------------
// PALETA DE COLORES PASTEL (Formato BGR Win32 para Enterprise Architect)
// BGR = Red + (Green * 256) + (Blue * 65536)
// ---------------------------------------------------------------------------
var COLOR_CLIENTE_ADMIN = 14084351; // Melocotón Pastel (#FFE8D6): R=255, G=232, B=214
var COLOR_SERVIDORES    = 16692956; // Azul Cielo Pastel (#DCEEFE): R=220, G=238, B=254
var COLOR_RED_INTERNET  = 15788258; // Pizarra / Gris (#E2E8F0):    R=226, G=232, B=240
var COLOR_EXTERNOS      = 16181229; // Lavanda Pastel (#EDE7F6):   R=237, G=231, B=246
var COLOR_EXEC_ENV      = 16381425; // Blanco Hielo (#F1F5F9):     R=241, G=245, B=249
var COLOR_ARTEFACTO     = 16777215; // Blanco Puro (#FFFFFF):      R=255, G=255, B=255

function log(msg) {
    try { Session.Output("[Despliegue-FashionStore] " + msg); } catch (e) { WScript.Echo(msg); }
}

/**
 * Obtiene el paquete de destino en el Project Browser o lo crea si no existe.
 */
function getTargetPackage() {
    var selectedPkg = Repository.GetTreeSelectedPackage();
    if (selectedPkg != null) {
        log("Usando paquete seleccionado en Project Browser: " + selectedPkg.Name);
        return selectedPkg;
    }

    var roots = Repository.Models;
    var root = (roots.Count > 0) ? roots.GetAt(0) : null;
    if (root == null) {
        Session.Prompt("No se encontró ningún modelo raíz en Enterprise Architect.", 0);
        return null;
    }

    for (var i = 0; i < root.Packages.Count; i++) {
        var p = root.Packages.GetAt(i);
        if (p.Name == DEFAULT_PACKAGE_NAME) {
            return p;
        }
    }

    var newPkg = root.Packages.AddNew(DEFAULT_PACKAGE_NAME, "Package");
    newPkg.Update();
    root.Packages.Refresh();
    log("Paquete creado: " + DEFAULT_PACKAGE_NAME);
    return newPkg;
}

/**
 * Recrea el diagrama de despliegue limpio.
 */
function recreateDiagram(pkg) {
    for (var i = pkg.Diagrams.Count - 1; i >= 0; i--) {
        var d = pkg.Diagrams.GetAt(i);
        if (d.Name == DIAGRAM_NAME) {
            try {
                pkg.Diagrams.Delete(i);
                pkg.Diagrams.Refresh();
                log("Diagrama previo eliminado para regeneración limpia.");
            } catch (e) {
                log("Aviso al eliminar: " + e.message);
            }
            break;
        }
    }

    var diagram = pkg.Diagrams.AddNew(DIAGRAM_NAME, "Deployment");
    diagram.Update();
    pkg.Diagrams.Refresh();
    return diagram;
}

/**
 * Crea un Nodo UML (Device o Node) con su color pastel y lo posiciona en el diagrama.
 */
function addNode(pkg, diagram, name, stereotype, notes, l, r, t, b, bgrColor) {
    var el = pkg.Elements.AddNew(name, "Node");
    if (stereotype && stereotype.length > 0) {
        el.Stereotype = stereotype;
    }
    if (notes && notes.length > 0) {
        el.Notes = notes;
    }
    try {
        if (bgrColor) {
            el.SetAppearance(1, 0, bgrColor);
        }
    } catch(e) {}
    el.Update();
    pkg.Elements.Refresh();

    var dObj = diagram.DiagramObjects.AddNew("l=" + l + ";r=" + r + ";t=" + t + ";b=" + b + ";", "");
    dObj.ElementID = el.ElementID;
    if (bgrColor) {
        try { dObj.BackgroundColor = bgrColor; } catch(e) {}
    }
    dObj.Update();

    return el;
}

/**
 * Crea un Entorno de Ejecución (Execution Environment) dentro de un Nodo con color diferenciado.
 */
function addExecutionEnv(parentNode, diagram, name, stereotype, l, r, t, b, bgrColor) {
    var env = parentNode.Elements.AddNew(name, "ExecutionEnvironment");
    if (stereotype && stereotype.length > 0) {
        env.Stereotype = stereotype;
    }
    try {
        if (bgrColor) {
            env.SetAppearance(1, 0, bgrColor);
        }
    } catch(e) {}
    env.Update();
    parentNode.Elements.Refresh();

    var dObj = diagram.DiagramObjects.AddNew("l=" + l + ";r=" + r + ";t=" + t + ";b=" + b + ";", "");
    dObj.ElementID = env.ElementID;
    if (bgrColor) {
        try { dObj.BackgroundColor = bgrColor; } catch(e) {}
    }
    dObj.Update();

    return env;
}

/**
 * Crea un Artefacto UML como elemento hijo dentro de un Nodo o Entorno.
 */
function addArtifact(parentNode, diagram, name, stereotype, l, r, t, b, bgrColor) {
    var art = parentNode.Elements.AddNew(name, "Artifact");
    if (stereotype && stereotype.length > 0) {
        art.Stereotype = stereotype;
    }
    try {
        if (bgrColor) {
            art.SetAppearance(1, 0, bgrColor);
        }
    } catch(e) {}
    art.Update();
    parentNode.Elements.Refresh();

    var dObj = diagram.DiagramObjects.AddNew("l=" + l + ";r=" + r + ";t=" + t + ";b=" + b + ";", "");
    dObj.ElementID = art.ElementID;
    if (bgrColor) {
        try { dObj.BackgroundColor = bgrColor; } catch(e) {}
    }
    dObj.Update();

    return art;
}

/**
 * Crea una vía de comunicación (CommunicationPath) con etiqueta de protocolo.
 */
function addCommunication(src, dst, protocolLabel) {
    var con = src.Connectors.AddNew(protocolLabel, "CommunicationPath");
    con.SupplierID = dst.ElementID;
    con.Direction = "Source -> Destination";
    con.Update();
    return con;
}

function main() {
    log("Iniciando generación del Diagrama de Despliegue Físico y Cloud (FashionStore)...");

    var pkg = getTargetPackage();
    if (pkg == null) return;

    var diagram = recreateDiagram(pkg);

    /* =========================================================================
     * 1. FILA SUPERIOR: FRONTEND VERCEL, RED INTERNET Y DISPOSITIVO ADMIN
     * ========================================================================= */
    // [Top-Left] Servidor Web Frontend (Vercel Cloud Platform) - AZUL SERVIDORES
    var nodoFrontend = addNode(
        pkg, diagram,
        "Servidor Web Frontend\n(Vercel Cloud Platform)",
        "device",
        "Plataforma de Vercel que publica el frontend como recursos estáticos y PWA distribuidos por su red perimetral Edge.",
        40, 380, -40, -300,
        COLOR_SERVIDORES
    );
    var envVercel = addExecutionEnv(
        nodoFrontend, diagram,
        "Vercel Edge Network\n(hosting estático / CDN)",
        "executionEnvironment",
        60, 360, -100, -285,
        COLOR_EXEC_ENV
    );
    addArtifact(envVercel, diagram, "FashionStore Web Bundle\n(Angular 21)", "artifact", 80, 340, -125, -195, COLOR_ARTEFACTO);
    addArtifact(envVercel, diagram, "decart-try-on.html\n(Decart Realtime SDK)", "artifact", 80, 340, -210, -270, COLOR_ARTEFACTO);

    // [Center-Top] Red Internet (WAN / Red Pública Segura) - GRIS PIZARRA
    var nodoInternet = addNode(
        pkg, diagram,
        "Red Internet\n(WAN / Red Pública Segura)",
        "device",
        "Red pública de telecomunicaciones por la que los dispositivos acceden a la plataforma; toda la comunicación viaja cifrada con HTTPS (TLS 1.3).",
        540, 840, -40, -140,
        COLOR_RED_INTERNET
    );

    // [Top-Right] Dispositivo Sucursal / Admin (Terminal POS) - MELOCOTÓN CLIENTE/ADMIN
    var nodoAdmin = addNode(
        pkg, diagram,
        "Dispositivo Sucursal / Admin\n(PC Escritorio / Terminal POS)",
        "device",
        "Computadora o terminal de punto de venta físico desde la que el personal de la empresa usa el panel web y POS (Online/Offline).",
        980, 1340, -40, -180,
        COLOR_CLIENTE_ADMIN
    );
    addArtifact(nodoAdmin, diagram, "Admin Dashboard SPA\n(Angular Web App)", "artifact", 1010, 1310, -95, -165, COLOR_ARTEFACTO);

    /* =========================================================================
     * 2. COLUMNA IZQUIERDA: SERVICIOS EXTERNOS IA Y MENSAJERÍA (LAVANDA PASTEL)
     * ========================================================================= */
    // Google Cloud - Gemini AI
    var nodoGemini = addNode(
        pkg, diagram,
        "Google Cloud - Gemini AI\n(Asistente inteligente e IA)",
        "node",
        "Chatbot multimodal, reportes en lenguaje natural, extracción RPA y recorte predictivo de prendas.",
        40, 360, -340, -460,
        COLOR_EXTERNOS
    );
    addArtifact(nodoGemini, diagram, "Gemini API (google-genai)", "artifact", 60, 340, -385, -445, COLOR_ARTEFACTO);

    // Hugging Face Space (Probador virtual por foto / Lucy VTON)
    var nodoHuggingFace = addNode(
        pkg, diagram,
        "Hugging Face Space\n(Probador virtual por foto)",
        "node",
        "Vestidor virtual fotográfico basado en el modelo IDM-VTON / Lucy VTON para adaptación de prendas.",
        40, 360, -500, -620,
        COLOR_EXTERNOS
    );
    addArtifact(nodoHuggingFace, diagram, "IDM-VTON (gradio_client)", "artifact", 60, 340, -545, -605, COLOR_ARTEFACTO);

    // Mailtrap (Envío transaccional de correos)
    var nodoMailtrap = addNode(
        pkg, diagram,
        "Mailtrap\n(Envío de correos)",
        "node",
        "Envío transaccional de credenciales, recuperación de contraseña y comprobantes digitales de compra por correo.",
        40, 360, -660, -780,
        COLOR_EXTERNOS
    );
    addArtifact(nodoMailtrap, diagram, "Mailtrap Email Sending API", "artifact", 60, 340, -705, -765, COLOR_ARTEFACTO);

    /* =========================================================================
     * 3. COLUMNA CENTRAL: SERVIDOR BACKEND SAAS Y BASE DE DATOS (AZUL SERVIDORES)
     * ========================================================================= */
    // Servidor Backend (Render Cloud Platform / Docker Web Service)
    var nodoBackend = addNode(
        pkg, diagram,
        "Servidor Backend\n(Render Cloud - Docker + FastAPI)",
        "device",
        "Servidor cloud administrado con certificado TLS que ejecuta el backend en contenedor Docker Python 3.12 y atiende /api.",
        440, 840, -280, -680,
        COLOR_SERVIDORES
    );
    var envDocker = addExecutionEnv(
        nodoBackend, diagram,
        "Contenedor Docker\n(Python 3.12 + FastAPI)",
        "executionEnvironment",
        460, 820, -345, -660,
        COLOR_EXEC_ENV
    );
    addArtifact(envDocker, diagram, "FashionStore REST API\n(FastAPI / Uvicorn :8000)", "artifact", 480, 800, -380, -470, COLOR_ARTEFACTO);
    addArtifact(envDocker, diagram, "Tareas en segundo plano\n(main.py: vencimientos, reposicion, comprobantes)", "artifact", 480, 800, -495, -635, COLOR_ARTEFACTO);

    // Servidor Base de Datos (Neon Cloud Serverless PostgreSQL 16)
    var nodoDatabase = addNode(
        pkg, diagram,
        "Servidor Base de Datos\n(Neon Cloud PostgreSQL 16)",
        "device",
        "Motor PostgreSQL 16 Serverless administrado en la nube con soporte multitenant (tenant_id) y transacciones ACID.",
        440, 840, -760, -960,
        COLOR_SERVIDORES
    );
    var envPostgres = addExecutionEnv(
        nodoDatabase, diagram,
        "PostgreSQL DBMS Engine",
        "executionEnvironment",
        460, 820, -815, -940,
        COLOR_EXEC_ENV
    );
    addArtifact(envPostgres, diagram, "Esquema BD relacional FashionStore\n(58 tablas multi-tenant)", "artifact", 480, 800, -850, -925, COLOR_ARTEFACTO);

    /* =========================================================================
     * 4. COLUMNA CENTRO-DERECHA: SERVICIOS EXTERNOS GATEWAYS (LAVANDA PASTEL)
     * ========================================================================= */
    // Pasarela de Pago (Stripe Payments)
    var nodoStripe = addNode(
        pkg, diagram,
        "Pasarela de Pago\n(Stripe Payments)",
        "node",
        "Pasarela certificada PCI-DSS para cobros con tarjeta, PaymentIntent y notificaciones por Webhooks criptográficos.",
        920, 1220, -260, -380,
        COLOR_EXTERNOS
    );
    addArtifact(nodoStripe, diagram, "Stripe Payments REST API", "artifact", 940, 1200, -305, -365, COLOR_ARTEFACTO);

    // Firebase Cloud Messaging (Notificaciones push)
    var nodoFirebase = addNode(
        pkg, diagram,
        "Firebase Cloud Messaging\n(Notificaciones push)",
        "node",
        "Servicio de Google Firebase para despacho de notificaciones push a la PWA Web y aplicación móvil Flutter.",
        920, 1220, -420, -540,
        COLOR_EXTERNOS
    );
    addArtifact(nodoFirebase, diagram, "FCM HTTP v1 API", "artifact", 940, 1200, -465, -525, COLOR_ARTEFACTO);

    // Cloudinary Media Cloud (Gestión y CDN de multimedia)
    var nodoCloudinary = addNode(
        pkg, diagram,
        "Cloudinary Media Cloud\n(Gestión y CDN de multimedia)",
        "node",
        "Almacenamiento seguro, optimización responsiva y CDN perimetral para imágenes del catálogo y logos de empresas.",
        920, 1220, -580, -700,
        COLOR_EXTERNOS
    );
    addArtifact(nodoCloudinary, diagram, "Cloudinary REST & CDN API", "artifact", 940, 1200, -625, -685, COLOR_ARTEFACTO);

    /* =========================================================================
     * 5. COLUMNA DERECHA: DISPOSITIVO CLIENTE Y DECART AI (REALTIME AR)
     * ========================================================================= */
    // Dispositivo Cliente (PC / Laptop / Smartphone Android) - MELOCOTÓN CLIENTE/ADMIN
    var nodoCliente = addNode(
        pkg, diagram,
        "Dispositivo Cliente\n(PC / Laptop / Smartphone Android)",
        "device",
        "Dispositivo del cliente que utiliza la aplicación web o la aplicación móvil para catálogo, reservas y probador.",
        1300, 1660, -280, -580,
        COLOR_CLIENTE_ADMIN
    );
    addArtifact(nodoCliente, diagram, "Web Client App\n(Angular SPA)", "artifact", 1330, 1630, -345, -420, COLOR_ARTEFACTO);
    addArtifact(nodoCliente, diagram, "Mobile Client App\n(Flutter / Dart)", "artifact", 1330, 1630, -450, -535, COLOR_ARTEFACTO);

    // Decart AI (Probador virtual en tiempo real) - LAVANDA PASTEL
    var nodoDecart = addNode(
        pkg, diagram,
        "Decart AI\n(Probador virtual en tiempo real)",
        "node",
        "Servicio de Inteligencia Artificial para vestidor y prueba de prendas en tiempo real mediante cámara y WebRTC.",
        1300, 1640, -660, -780,
        COLOR_EXTERNOS
    );
    addArtifact(nodoDecart, diagram, "Decart Realtime API", "artifact", 1320, 1620, -705, -765, COLOR_ARTEFACTO);

    /* =========================================================================
     * 6. VÍAS DE COMUNICACIÓN (Communication Paths con Protocolos Exactos)
     * ========================================================================= */
    // Acceso de Clientes y Administradores a Internet
    addCommunication(nodoAdmin, nodoInternet, "HTTPS :443 (TLS 1.3)");
    addCommunication(nodoCliente, nodoInternet, "HTTPS :443 (Wi-Fi / 4G)");

    // Tránsito de Internet a Plataformas Cloud
    addCommunication(nodoInternet, nodoFrontend, "HTTPS :443 (descarga la SPA)");
    addCommunication(nodoInternet, nodoBackend, "HTTPS :443 REST/JSON + JWT");

    // Conexión Backend -> Base de Datos
    addCommunication(nodoBackend, nodoDatabase, "psycopg2 / TCP :5432");

    // Conexiones Backend -> Servicios Externos
    addCommunication(nodoBackend, nodoGemini, "HTTPS :443 (REST API)");
    addCommunication(nodoBackend, nodoHuggingFace, "HTTPS :443 (Inference API)");
    addCommunication(nodoBackend, nodoMailtrap, "HTTPS :443 (Email API)");
    addCommunication(nodoBackend, nodoStripe, "HTTPS :443 (Payment Intents / webhook)");
    addCommunication(nodoBackend, nodoFirebase, "HTTPS :443 (envio push)");
    addCommunication(nodoBackend, nodoCloudinary, "HTTPS :443 (Media Upload API)");

    // Conexiones Directas Dispositivo Cliente -> Servicios Externos
    addCommunication(nodoCliente, nodoStripe, "HTTPS :443 (Stripe.js / flutter_stripe)");
    addCommunication(nodoFirebase, nodoCliente, "push");
    addCommunication(nodoCliente, nodoCloudinary, "HTTPS :443 (CDN Image Fetch)");
    addCommunication(nodoCliente, nodoDecart, "HTTPS / WebRTC (AR Video Stream)");

    /* =========================================================================
     * 7. GUARDAR, REFRESCAR Y ABRIR DIAGRAMA
     * ========================================================================= */
    diagram.Update();
    Repository.SaveDiagram(diagram.DiagramID);
    Repository.ReloadDiagram(diagram.DiagramID);
    Repository.OpenDiagram(diagram.DiagramID);

    log("Diagrama '" + DIAGRAM_NAME + "' generado exitosamente con topología completa y colores diferenciados.");
    try {
        var msg = "Diagrama de Despliegue Físico y Cloud actualizado exitosamente!\n\n" +
                  "- Frontend: Vercel Cloud Platform (Angular 21 + decart-try-on.html)\n" +
                  "- Backend: Render Cloud Platform (Python 3.12 + FastAPI + Background Tasks)\n" +
                  "- Base de Datos: Neon Cloud Serverless PostgreSQL 16 (58 tablas multi-tenant)\n" +
                  "- Dispositivos: Sucursal/Admin (POS) y Cliente (Web Angular + Mobile Flutter)\n" +
                  "- Servicios Externos: Gemini AI, Hugging Face, Mailtrap, Stripe, FCM, Cloudinary, Decart AI\n" +
                  "- Colores pasteles aplicados: Dispositivos (Melocotón), Servidores (Azul Cielo), Servicios (Lavanda).";
        Session.Prompt(msg, 0);
    } catch(e) {}
}

main();

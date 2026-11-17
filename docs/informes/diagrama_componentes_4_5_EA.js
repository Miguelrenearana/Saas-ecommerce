// ============================================================================
// Diagrama de Implementación e Integración de Componentes (Capítulo 4.5)
// Enterprise Architect 15.0+ — Motor JScript WSH
// FashionStore — Plataforma E-Commerce SaaS Multitenant
//
// CARACTERÍSTICAS TÉCNICAS UML 2.5+:
//   - Subsistemas / Contenedores: Web (Angular PWA), Movil (Flutter) y Api (FastAPI).
//   - Componentes Internos con dependencias «use».
//   - Componentes Externos: Stripe Gateway, Gemini IA, PostgreSQL 15+.
//   - Interfaces Provistas y Requeridas (Ball-and-Socket / Piruleta y Receptor):
//       * HTTP/json        : Expuesta por Api.Middleware, consumida por Web y Movil.
//       * API/stripe       : Expuesta por Stripe, consumida por Web, Movil y Api.ventas.
//       * API/Gemini       : Expuesta por Gemini IA, consumida por Api.administracion.
//       * TCP/ puerto 5432 : Expuesta por PostgreSQL, consumida por Api.Models.
// ============================================================================

function Log(msg) {
    Session.Output("[FashionStore-CMP-4.5] " + msg);
}

var Repo = (typeof Repository != "undefined") ? Repository : null;
if (Repo == null) {
    try {
        var eaApp = GetObject("", "EA.App");
        Repo = eaApp.Repository;
    } catch(e) {
        Session.Prompt("Error: No se pudo obtener el objeto Repository de Enterprise Architect.", 0);
    }
}

function Main() {
    Log("Iniciando generación de Diagrama de Componentes 4.5 en Enterprise Architect...");

    var packageDestino = Repo.GetTreeSelectedPackage();
    if (packageDestino == null) {
        if (Repo.Models.Count > 0) {
            packageDestino = Repo.Models.GetAt(0);
        } else {
            Session.Prompt("Error: Seleccione un modelo o paquete en el Project Browser.", 0);
            return;
        }
    }

    // 1. Crear Paquete Contenedor
    var pkg = packageDestino.Packages.AddNew("4.5 Integración de Componentes", "");
    pkg.Update();

    // 2. Crear Diagrama de Componentes UML
    var diagram = pkg.Diagrams.AddNew("cmp Diagrama de implementación de componentes", "Component");
    diagram.Update();

    var elements = {};

    // Función auxiliar para crear componentes
    function createComp(name, parentPkg, stereotype, parentComp) {
        var comp;
        if (parentComp != null) {
            comp = parentComp.Elements.AddNew(name, "Component");
        } else {
            comp = parentPkg.Elements.AddNew(name, "Component");
        }
        if (stereotype != null && stereotype != "") {
            comp.Stereotype = stereotype;
        }
        comp.Update();
        elements[name] = comp;
        return comp;
    }

    // Función auxiliar para crear interfaces
    function createInterface(name, parentPkg) {
        var iface = parentPkg.Elements.AddNew(name, "Interface");
        iface.Update();
        elements[name] = iface;
        return iface;
    }

    // Función auxiliar para agregar al diagrama con coordenadas
    function placeOnDiagram(elem, l, t, r, b) {
        var dObj = diagram.DiagramObjects.AddNew("l=" + l + ";r=" + r + ";t=" + t + ";b=" + b + ";", "");
        dObj.ElementID = elem.ElementID;
        dObj.Update();
        return dObj;
    }

    // ------------------------------------------------------------------------
    // A. CREACIÓN DE COMPONENTES CONTENEDORES PRINCIPALES
    // ------------------------------------------------------------------------
    Log("Creando subsistemas principales (Web, Movil, Api)...");

    var compWeb   = createComp("Web", pkg, "", null);
    var compMovil = createComp("Movil", pkg, "", null);
    var compApi   = createComp("Api", pkg, "", null);

    // ------------------------------------------------------------------------
    // B. COMPONENTES INTERNOS DE 'Web' (Angular 21 PWA)
    // ------------------------------------------------------------------------
    var webViews    = createComp("Views", pkg, "", compWeb);
    var webServices = createComp("Services", pkg, "", compWeb);
    var webOffline  = createComp("Offline", pkg, "", compWeb);

    // ------------------------------------------------------------------------
    // C. COMPONENTES INTERNOS DE 'Movil' (Flutter)
    // ------------------------------------------------------------------------
    var movView       = createComp("View", pkg, "", compMovil);
    var movServices   = createComp("Services_Movil", pkg, "", compMovil);
    movServices.Name  = "Services";
    movServices.Update();
    var movVestidorRA = createComp("Vestidor RA", pkg, "", compMovil);
    var movOffline    = createComp("Offline_Movil", pkg, "", compMovil);
    movOffline.Name   = "Offline";
    movOffline.Update();

    // ------------------------------------------------------------------------
    // D. COMPONENTES INTERNOS DE 'Api' (FastAPI Backend)
    // ------------------------------------------------------------------------
    var apiMiddleware    = createComp("Middleware", pkg, "", compApi);
    var apiMultitenant   = createComp("Multitennant", pkg, "", compApi);
    var apiCatalog       = createComp("catalog", pkg, "", compApi);
    var apiVentas        = createComp("ventas", pkg, "", compApi);
    var apiAdmin         = createComp("administracion", pkg, "", compApi);
    var apiModels        = createComp("Models", pkg, "", compApi);

    // ------------------------------------------------------------------------
    // E. COMPONENTES EXTERNOS
    // ------------------------------------------------------------------------
    var extStripe   = createComp("Stripe", pkg, "externo", null);
    var extGemini   = createComp("Gemini IA", pkg, "externo", null);
    var extPostgres = createComp("Postgresql", pkg, "Base de datos", null);

    // ------------------------------------------------------------------------
    // F. INTERFACES (Ball and Socket)
    // ------------------------------------------------------------------------
    Log("Creando interfaces provistas y requeridas (Ball-and-Socket)...");
    var ifaceHttpJson   = createInterface("HTTP/json", pkg);
    var ifaceStripe     = createInterface("API/stripe", pkg);
    var ifaceGemini     = createInterface("API/Gemini", pkg);
    var ifacePostgresql = createInterface("TCP/ puerto 5432", pkg);

    // ------------------------------------------------------------------------
    // G. RELACIONES INTERNAS «use» (Dependency)
    // ------------------------------------------------------------------------
    function addUsage(sourceElem, targetElem) {
        var conn = sourceElem.Connectors.AddNew("", "Dependency");
        conn.Stereotype = "use";
        conn.SupplierID = targetElem.ElementID;
        conn.Update();
        return conn;
    }

    // En Web
    addUsage(webViews, webServices);
    addUsage(webServices, webOffline);

    // En Movil
    addUsage(movView, movServices);
    addUsage(movServices, movVestidorRA);
    addUsage(movVestidorRA, movOffline);
    addUsage(movServices, movOffline);

    // En Api
    addUsage(apiMiddleware, apiMultitenant);
    addUsage(apiMultitenant, apiCatalog);
    addUsage(apiMultitenant, apiVentas);
    addUsage(apiMultitenant, apiAdmin);
    addUsage(apiCatalog, apiVentas);
    addUsage(apiCatalog, apiModels);
    addUsage(apiVentas, apiModels);
    addUsage(apiAdmin, apiModels);

    // ------------------------------------------------------------------------
    // H. CONECTORES BALL-AND-SOCKET (Realization = Ball, Dependency/Usage = Socket)
    // ------------------------------------------------------------------------
    function addProvided(compElem, ifaceElem) {
        // En UML/EA: Realization desde el componente proveedor hacia la interfaz = Lollipop / Ball (—O)
        var conn = compElem.Connectors.AddNew("", "Realization");
        conn.SupplierID = ifaceElem.ElementID;
        conn.Update();
        return conn;
    }

    function addRequired(compElem, ifaceElem) {
        // En UML/EA: Dependency/Usage desde el consumidor hacia la interfaz = Socket / Receptor (—))
        var conn = compElem.Connectors.AddNew("", "Dependency");
        conn.Stereotype = "use";
        conn.SupplierID = ifaceElem.ElementID;
        conn.Update();
        return conn;
    }

    // 1. Interfaz HTTP/json
    addProvided(apiMiddleware, ifaceHttpJson);
    addRequired(webServices, ifaceHttpJson);
    addRequired(movServices, ifaceHttpJson);

    // 2. Interfaz API/stripe
    addProvided(extStripe, ifaceStripe);
    addRequired(compWeb, ifaceStripe);
    addRequired(compMovil, ifaceStripe);
    addRequired(apiVentas, ifaceStripe);

    // 3. Interfaz API/Gemini
    addProvided(extGemini, ifaceGemini);
    addRequired(apiAdmin, ifaceGemini);

    // 4. Interfaz TCP/ puerto 5432
    addProvided(extPostgres, ifacePostgresql);
    addRequired(apiModels, ifacePostgresql);

    // ------------------------------------------------------------------------
    // I. DISTRIBUCIÓN ESPACIAL Y COORDENADAS EN EL LIENZO
    // ------------------------------------------------------------------------
    Log("Posicionando elementos y ajustando layout visual...");

    // Contenedor Web (Izquierda - Arriba)
    placeOnDiagram(compWeb, 40, -50, 320, -360);
    placeOnDiagram(webViews, 80, -90, 280, -150);
    placeOnDiagram(webServices, 80, -180, 280, -240);
    placeOnDiagram(webOffline, 80, -270, 280, -330);

    // Contenedor Movil (Izquierda - Abajo)
    placeOnDiagram(compMovil, 40, -400, 320, -820);
    placeOnDiagram(movView, 80, -440, 280, -500);
    placeOnDiagram(movServices, 80, -530, 280, -590);
    placeOnDiagram(movVestidorRA, 80, -620, 280, -700);
    placeOnDiagram(movOffline, 80, -730, 280, -790);

    // Contenedor Api (Centro / Derecha)
    placeOnDiagram(compApi, 560, -50, 840, -660);
    placeOnDiagram(apiMiddleware, 600, -90, 800, -150);
    placeOnDiagram(apiMultitenant, 600, -180, 800, -240);
    placeOnDiagram(apiCatalog, 590, -280, 680, -370);
    placeOnDiagram(apiVentas, 570, -390, 650, -470);
    placeOnDiagram(apiAdmin, 710, -280, 810, -370);
    placeOnDiagram(apiModels, 600, -530, 800, -620);

    // Interfaces (Ball-and-Socket) entre componentes
    placeOnDiagram(ifaceHttpJson, 420, -190, 460, -230);
    placeOnDiagram(ifaceStripe, 370, -640, 410, -680);
    placeOnDiagram(ifaceGemini, 880, -300, 920, -340);
    placeOnDiagram(ifacePostgresql, 690, -670, 730, -710);

    // Componentes Externos
    placeOnDiagram(extStripe, 380, -740, 520, -840);
    placeOnDiagram(extGemini, 940, -270, 1070, -370);
    placeOnDiagram(extPostgres, 580, -730, 770, -840);

    // Guardar y refrescar diagrama
    diagram.Update();
    Repo.ReloadDiagram(diagram.DiagramID);

    Log("¡Diagrama 4.5 generado exitosamente con interfaces Ball-and-Socket en Enterprise Architect!");
}

Main();

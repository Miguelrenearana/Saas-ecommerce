import sys
import os
import uuid
from datetime import datetime, timedelta, timezone

sys.path.insert(0, os.path.abspath("backend"))
os.chdir("backend")

from app.core.database import SessionLocal
from sqlalchemy import text
from app.packages.p3_gestion_inventario_disponibilidad.schemas.replenishment_schema import ReplenishmentStatusEnum

def populate():
    """
    Poblador de datos realistas para:
    - CU11: Traslados de Mercadería entre Sucursales (inventory_transfers)
    - Abastecimiento y Solicitudes de Reposición a Proveedores (replenishment_requests)
    para el tenant Boutique Elegance.
    """
    db = SessionLocal()
    try:
        # 1. Tenant Elegance
        tenant = db.execute(text("SELECT id, name FROM companies WHERE name ILIKE '%elegance%'")).fetchone()
        if not tenant:
            print("ERROR: Tenant Elegance no encontrado")
            return
        tenant_id, tenant_name = tenant
        print(f"Poblando datos para {tenant_name} ({tenant_id})...")

        # 2. Sucursales
        branches = db.execute(text("SELECT id, name FROM branches WHERE tenant_id = :t_id ORDER BY name"), {"t_id": tenant_id}).fetchall()
        print(f"Sucursales encontradas: {len(branches)}")
        if len(branches) < 2:
            print("ERROR: Se necesitan al menos 2 sucursales")
            return
        b_central = branches[0][0]
        b_equipetrol = branches[1][0]
        b_ventura = branches[2][0] if len(branches) > 2 else branches[1][0]
        b_cinecenter = branches[3][0] if len(branches) > 3 else branches[0][0]
        b_lapaz = branches[4][0] if len(branches) > 4 else branches[1][0]

        # 3. Usuarios Staff
        admin_user = db.execute(text("SELECT id, email FROM users WHERE tenant_id = :t_id AND rol = 'administrador'"), {"t_id": tenant_id}).fetchone()
        encargados = db.execute(text("SELECT id, email, branch_id FROM users WHERE tenant_id = :t_id AND rol = 'encargado'"), {"t_id": tenant_id}).fetchall()
        
        admin_id = admin_user[0] if admin_user else None
        encargado_id = encargados[0][0] if encargados else admin_id

        # Proveedores de la plataforma
        providers = db.execute(text("SELECT p.id, p.business_name, p.user_id FROM providers p ORDER BY p.business_name")).fetchall()
        print(f"Proveedores encontrados: {len(providers)}")
        if not providers:
            print("ERROR: No se encontraron proveedores")
            return

        # 4. Asignar proveedores a productos de Elegance que no tengan proveedor
        products = db.execute(text("SELECT id, name FROM products WHERE tenant_id = :t_id ORDER BY name"), {"t_id": tenant_id}).fetchall()
        print(f"Productos de Elegance: {len(products)}")
        for idx, prod in enumerate(products):
            prov = providers[idx % len(providers)]
            db.execute(text("UPDATE products SET provider_id = :prov_id WHERE id = :p_id AND provider_id IS NULL"), {"prov_id": prov[0], "p_id": prod[0]})
        db.commit()

        # Variantes de Elegance con proveedor
        variants_query = text("""
            SELECT pv.id, p.name, p.provider_id, pv.sku, pv.price
            FROM product_variants pv
            JOIN products p ON pv.product_id = p.id
            WHERE p.tenant_id = :t_id AND p.provider_id IS NOT NULL
            ORDER BY p.name, pv.sku
        """)
        variants = db.execute(variants_query, {"t_id": tenant_id}).fetchall()
        print(f"Variantes disponibles con proveedor: {len(variants)}")
        if len(variants) < 10:
            print("ERROR: Menos de 10 variantes encontradas")
            return

        # 5. Asegurar disponibilidad en ProviderVariantAvailability
        for v in variants[:30]:
            v_id, _, prov_id, _, _ = v
            exists = db.execute(text("SELECT id FROM provider_variant_availability WHERE provider_id = :p_id AND variant_id = :v_id"), {"p_id": prov_id, "v_id": v_id}).fetchone()
            if not exists:
                db.execute(text("""
                    INSERT INTO provider_variant_availability (id, provider_id, variant_id, quantity)
                    VALUES (:id, :p_id, :v_id, :qty)
                """), {"id": str(uuid.uuid4()), "p_id": prov_id, "v_id": v_id, "qty": 150})
        db.commit()

        # 6. Asegurar stock en branches para variantes
        for b_id in [b_central, b_equipetrol, b_ventura, b_cinecenter, b_lapaz]:
            for v in variants[:20]:
                v_id = v[0]
                inv = db.execute(text("SELECT id, quantity FROM inventory WHERE branch_id = :b_id AND variant_id = :v_id"), {"b_id": b_id, "v_id": v_id}).fetchone()
                if not inv:
                    db.execute(text("""
                        INSERT INTO inventory (id, tenant_id, branch_id, variant_id, quantity, reserved_quantity, minimum_stock)
                        VALUES (:id, :t_id, :b_id, :v_id, 45, 0, 5)
                    """), {"id": str(uuid.uuid4()), "t_id": tenant_id, "b_id": b_id, "v_id": v_id})
                elif inv[1] < 15:
                    db.execute(text("UPDATE inventory SET quantity = 45 WHERE id = :id"), {"id": inv[0]})
        db.commit()

        # 7. Limpiar traslados y solicitudes previas para poblar consistente
        db.execute(text("DELETE FROM inventory_transfers WHERE tenant_id = :t_id"), {"t_id": tenant_id})
        db.execute(text("""
            DELETE FROM replenishment_requests 
            WHERE branch_id IN (SELECT id FROM branches WHERE tenant_id = :t_id)
        """), {"t_id": tenant_id})
        db.commit()

        now = datetime.now(timezone.utc)

        # 8. POBLAR SOLICITUDES DE REPOSICIÓN (Replenishment Requests)
        print("Insertando Solicitudes de Reposición...")
        replenish_defs = [
            {
                "status": ReplenishmentStatusEnum.requested,
                "provider": providers[0],
                "branch_id": b_central,
                "created_at": now - timedelta(hours=4),
                "items": [(variants[0][0], 25), (variants[1][0], 30)],
            },
            {
                "status": ReplenishmentStatusEnum.accepted,
                "provider": providers[1 % len(providers)],
                "branch_id": b_equipetrol,
                "created_at": now - timedelta(days=1, hours=3),
                "accepted_at": now - timedelta(days=1),
                "items": [(variants[2][0], 20), (variants[3][0], 15), (variants[4][0], 10)],
            },
            {
                "status": ReplenishmentStatusEnum.preparing,
                "provider": providers[2 % len(providers)],
                "branch_id": b_ventura,
                "created_at": now - timedelta(days=2, hours=6),
                "accepted_at": now - timedelta(days=2, hours=2),
                "preparing_at": now - timedelta(days=1, hours=10),
                "items": [(variants[5][0], 40), (variants[6][0], 35)],
            },
            {
                "status": ReplenishmentStatusEnum.awaiting_receipt,
                "provider": providers[3 % len(providers)],
                "branch_id": b_cinecenter,
                "created_at": now - timedelta(days=3),
                "accepted_at": now - timedelta(days=2, hours=18),
                "preparing_at": now - timedelta(days=2),
                "awaiting_receipt_at": now - timedelta(hours=12),
                "items": [(variants[7][0], 15), (variants[8][0], 18)],
            },
            {
                "status": ReplenishmentStatusEnum.delivered,
                "provider": providers[0],
                "branch_id": b_lapaz,
                "created_at": now - timedelta(days=6),
                "accepted_at": now - timedelta(days=5),
                "preparing_at": now - timedelta(days=4),
                "awaiting_receipt_at": now - timedelta(days=3),
                "delivered_at": now - timedelta(days=1),
                "items": [(variants[9][0], 50), (variants[10][0], 40)],
            },
            {
                "status": ReplenishmentStatusEnum.requested,
                "provider": providers[1 % len(providers)],
                "branch_id": b_central,
                "created_at": now - timedelta(hours=1),
                "items": [(variants[11][0], 20), (variants[12][0], 25)],
            },
        ]

        for rep in replenish_defs:
            req_id = str(uuid.uuid4())
            prov_id, _, prov_user_id = rep["provider"]
            db.execute(text("""
                INSERT INTO replenishment_requests (
                    id, provider_id, branch_id, requested_by, status,
                    created_at, updated_at, accepted_by, accepted_at,
                    preparing_by, preparing_at, awaiting_receipt_by, awaiting_receipt_at,
                    delivered_by, delivered_at
                ) VALUES (
                    :id, :provider_id, :branch_id, :requested_by, :status,
                    :created_at, :updated_at, :accepted_by, :accepted_at,
                    :preparing_by, :preparing_at, :awaiting_receipt_by, :awaiting_receipt_at,
                    :delivered_by, :delivered_at
                )
            """), {
                "id": req_id,
                "provider_id": prov_id,
                "branch_id": rep["branch_id"],
                "requested_by": admin_id,
                "status": rep["status"].value,
                "created_at": rep["created_at"],
                "updated_at": now,
                "accepted_by": prov_user_id if rep.get("accepted_at") else None,
                "accepted_at": rep.get("accepted_at"),
                "preparing_by": prov_user_id if rep.get("preparing_at") else None,
                "preparing_at": rep.get("preparing_at"),
                "awaiting_receipt_by": prov_user_id if rep.get("awaiting_receipt_at") else None,
                "awaiting_receipt_at": rep.get("awaiting_receipt_at"),
                "delivered_by": admin_id if rep.get("delivered_at") else None,
                "delivered_at": rep.get("delivered_at"),
            })

            for v_id, qty in rep["items"]:
                db.execute(text("""
                    INSERT INTO replenishment_request_items (id, request_id, variant_id, requested_quantity)
                    VALUES (:id, :request_id, :variant_id, :qty)
                """), {"id": str(uuid.uuid4()), "request_id": req_id, "variant_id": v_id, "qty": qty})
        db.commit()
        print("Solicitudes de reposición insertadas con éxito.")

        # 9. POBLAR TRASLADOS DE MERCADERÍA (Inventory Transfers)
        print("Insertando Traslados de Mercadería...")
        transfer_defs = [
            {
                "num": "TRF-2026-0001",
                "from": b_central,
                "to": b_equipetrol,
                "status": "EN_TRANSITO",
                "req_by": admin_id,
                "rec_by": None,
                "req_at": now - timedelta(hours=5),
                "rec_at": None,
                "notes": "Despacho prioritario para abastecimiento de fin de semana en Equipetrol",
                "items": [(variants[0][0], 8, None), (variants[1][0], 12, None)],
            },
            {
                "num": "TRF-2026-0002",
                "from": b_ventura,
                "to": b_cinecenter,
                "status": "EN_TRANSITO",
                "req_by": encargado_id,
                "rec_by": None,
                "req_at": now - timedelta(hours=14),
                "rec_at": None,
                "notes": "Traspaso de prendas exclusivas para exhibición en Cine Center",
                "items": [(variants[2][0], 6, None)],
            },
            {
                "num": "TRF-2026-0003",
                "from": b_central,
                "to": b_ventura,
                "status": "COMPLETADO",
                "req_by": admin_id,
                "rec_by": encargado_id,
                "req_at": now - timedelta(days=2),
                "rec_at": now - timedelta(days=1, hours=18),
                "notes": "Mercadería recibida en perfectas condiciones y perchas actualizadas",
                "items": [(variants[3][0], 10, 10), (variants[4][0], 15, 15)],
            },
            {
                "num": "TRF-2026-0004",
                "from": b_equipetrol,
                "to": b_lapaz,
                "status": "COMPLETADO",
                "req_by": admin_id,
                "rec_by": encargado_id,
                "req_at": now - timedelta(days=5),
                "rec_at": now - timedelta(days=3),
                "notes": "Envío interdepartamental La Paz - recepción completa sin discrepancias",
                "items": [(variants[5][0], 20, 20)],
            },
            {
                "num": "TRF-2026-0005",
                "from": b_cinecenter,
                "to": b_central,
                "status": "COMPLETADO",
                "req_by": encargado_id,
                "rec_by": admin_id,
                "req_at": now - timedelta(days=7),
                "rec_at": now - timedelta(days=6),
                "notes": "Rebalanceo de inventario a casa matriz Central",
                "items": [(variants[6][0], 5, 5)],
            },
            {
                "num": "TRF-2026-0006",
                "from": b_central,
                "to": b_cinecenter,
                "status": "CANCELADO",
                "req_by": admin_id,
                "rec_by": None,
                "req_at": now - timedelta(days=4),
                "rec_at": None,
                "notes": "Cancelado: Cine Center confirmó contar con suficiente stock en depósito",
                "items": [(variants[7][0], 10, None)],
            },
            {
                "num": "TRF-2026-0007",
                "from": b_equipetrol,
                "to": b_ventura,
                "status": "EN_TRANSITO",
                "req_by": encargado_id,
                "rec_by": None,
                "req_at": now - timedelta(hours=2),
                "rec_at": None,
                "notes": "Transferencia de vestidos de fiesta por alta demanda",
                "items": [(variants[8][0], 7, None), (variants[9][0], 9, None)],
            },
            {
                "num": "TRF-2026-0008",
                "from": b_lapaz,
                "to": b_central,
                "status": "COMPLETADO",
                "req_by": encargado_id,
                "rec_by": admin_id,
                "req_at": now - timedelta(days=10),
                "rec_at": now - timedelta(days=8),
                "notes": "Acta de recepción definitiva firmada",
                "items": [(variants[10][0], 14, 14)],
            },
        ]

        for trf in transfer_defs:
            trf_id = str(uuid.uuid4())
            db.execute(text("""
                INSERT INTO inventory_transfers (
                    id, tenant_id, transfer_number, from_branch_id, to_branch_id,
                    status, requested_by, received_by, requested_at, received_at,
                    notes, created_at, updated_at
                ) VALUES (
                    :id, :tenant_id, :transfer_number, :from_branch_id, :to_branch_id,
                    :status, :requested_by, :received_by, :requested_at, :received_at,
                    :notes, :created_at, :updated_at
                )
            """), {
                "id": trf_id,
                "tenant_id": tenant_id,
                "transfer_number": trf["num"],
                "from_branch_id": trf["from"],
                "to_branch_id": trf["to"],
                "status": trf["status"],
                "requested_by": trf["req_by"],
                "received_by": trf["rec_by"],
                "requested_at": trf["req_at"],
                "received_at": trf["rec_at"],
                "notes": trf["notes"],
                "created_at": trf["req_at"],
                "updated_at": trf["rec_at"] or trf["req_at"],
            })

            for v_id, qty, rec_qty in trf["items"]:
                db.execute(text("""
                    INSERT INTO inventory_transfer_items (
                        id, transfer_id, variant_id, quantity, received_quantity, created_at
                    ) VALUES (
                        :id, :transfer_id, :variant_id, :quantity, :received_quantity, :created_at
                    )
                """), {
                    "id": str(uuid.uuid4()),
                    "transfer_id": trf_id,
                    "variant_id": v_id,
                    "quantity": qty,
                    "received_quantity": rec_qty,
                    "created_at": trf["req_at"],
                })

        db.commit()
        print("Traslados de mercadería insertados con éxito.")

        cnt_transfers = db.execute(text("SELECT count(*) FROM inventory_transfers WHERE tenant_id = :t_id"), {"t_id": tenant_id}).scalar()
        cnt_replenish = db.execute(text("""
            SELECT count(*) FROM replenishment_requests r
            JOIN branches b ON r.branch_id = b.id
            WHERE b.tenant_id = :t_id
        """), {"t_id": tenant_id}).scalar()

        print(f"\n==========================================")
        print(f"POBLACIÓN COMPLETADA PARA {tenant_name}:")
        print(f"-> Total Traslados: {cnt_transfers}")
        print(f"-> Total Solicitudes de Reposición: {cnt_replenish}")
        print(f"==========================================")

    except Exception as e:
        db.rollback()
        print("ERROR durante la población:", e)
        raise e
    finally:
        db.close()

if __name__ == "__main__":
    populate()

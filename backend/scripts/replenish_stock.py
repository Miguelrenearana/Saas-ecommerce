import os, sys
from pathlib import Path

backend_dir = Path(__file__).resolve().parent
if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

from dotenv import load_dotenv
load_dotenv(backend_dir / ".env")

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

database_url = os.getenv("DATABASE_URL") or "postgresql://neondb_owner:npg_6zU5oIcvwWsl@ep-square-snow-a87f549j-pooler.eastus2.azure.neon.tech/neondb?sslmode=require"
engine = create_engine(database_url)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db = SessionLocal()

try:
    print("1. Asignando tenant_id a sucursales huerfanas desde usuarios...")
    db.execute(text("""
        UPDATE branches b
        SET tenant_id = u.tenant_id
        FROM users u
        WHERE u.branch_id = b.id AND b.tenant_id IS NULL AND u.tenant_id IS NOT NULL
    """))
    # Si alguna queda sin tenant, asignarla al primer tenant existente
    first_tenant = db.execute(text("SELECT id FROM companies LIMIT 1")).scalar()
    if first_tenant:
        db.execute(text("UPDATE branches SET tenant_id = :tid WHERE tenant_id IS NULL"), {"tid": first_tenant})

    print("2. Corrigiendo tenant_id nulo en inventario...")
    db.execute(text("""
        UPDATE inventory i
        SET tenant_id = b.tenant_id
        FROM branches b
        WHERE i.branch_id = b.id AND i.tenant_id IS NULL
    """))

    print("3. Eliminando inventario cruzado invalido...")
    db.execute(text("""
        DELETE FROM inventory i
        USING branches b, product_variants pv, products p
        WHERE i.branch_id = b.id 
          AND i.variant_id = pv.id 
          AND pv.product_id = p.id
          AND b.tenant_id != p.tenant_id
    """))

    print("4. Rellenando stock masivamente en un solo comando SQL...")
    result = db.execute(text("""
        INSERT INTO inventory (id, branch_id, variant_id, tenant_id, quantity, reserved_quantity, minimum_stock)
        SELECT gen_random_uuid(), b.id, pv.id, b.tenant_id, 50, 0, 5
        FROM branches b
        JOIN products p ON p.tenant_id = b.tenant_id
        JOIN product_variants pv ON pv.product_id = p.id
        ON CONFLICT (branch_id, variant_id) 
        DO UPDATE SET 
            quantity = GREATEST(inventory.quantity, 50),
            reserved_quantity = 0,
            tenant_id = EXCLUDED.tenant_id
    """))
    db.commit()
    print("Exito total: Todas las combinaciones de sucursal-variante tienen stock >= 50.")
except Exception as e:
    db.rollback()
    print("Error:", e)
finally:
    db.close()

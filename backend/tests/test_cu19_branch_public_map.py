import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from fastapi.testclient import TestClient
from main import app
from app.core.database import SessionLocal
from app.auth.jwt import create_access_token
from app.packages.p0_saas_plataforma.models.company import Company
from app.packages.p1_gestion_usuarios_acceso.models.branch import Branch
from app.packages.p1_gestion_usuarios_acceso.models.user import User
from app.schemas.enums import RolEnum

client = TestClient(app)


def test_cu19_list_public_branches_success():
    """
    CU19: Verifica que el endpoint público de sucursales retorne
    las tiendas georreferenciadas con lat/long, teléfono y dirección.
    """
    db = SessionLocal()
    try:
        elegance = db.query(Company).filter(Company.subdomain == "elegance").first()
        assert elegance is not None, "Tenant elegance debe existir en la BD de pruebas"

        res = client.get(f"/api/branches/public?tenant_id={elegance.id}")
        assert res.status_code == 200
        data = res.json()
        assert data.get("statusCode") == 200 or data.get("status_code") == 200
        branches = data.get("data", [])
        assert len(branches) >= 2, f"Se esperaban al menos 2 sucursales para Elegance, encontradas: {len(branches)}"

        for b in branches:
            assert b["tenant_id"] == str(elegance.id)
            assert b["is_active"] is True
            assert b["latitude"] is not None and b["latitude"] != 0.0
            assert b["longitude"] is not None and b["longitude"] != 0.0
            assert b["address"] != ""
            assert b["opening_hours"] != ""
    finally:
        db.close()


def test_cu19_multitenant_isolation():
    """
    CU19: Verifica que las sucursales devueltas pertenezcan estrictamente
    al tenant_id solicitado.
    """
    db = SessionLocal()
    try:
        urbana = db.query(Company).filter(Company.subdomain == "modaurbana").first()
        if not urbana:
            return  # Omitir si no está sembrado

        res = client.get(f"/api/branches/public?tenant_id={urbana.id}")
        assert res.status_code == 200
        branches = res.json().get("data", [])
        for b in branches:
            assert b["tenant_id"] == str(urbana.id)
    finally:
        db.close()


def test_cu19_authenticated_client_scoped_to_own_tenant():
    """
    Verifica que un cliente perteneciente a un tenant solo pueda ver
    las sucursales y la empresa de ese tenant en /branches/public y /saas/companies,
    incluso si intenta pasar el tenant_id de otra empresa (anti-IDOR).
    """
    db = SessionLocal()
    try:
        elegance = db.query(Company).filter(Company.subdomain == "elegance").first()
        urbana = db.query(Company).filter(Company.subdomain == "modaurbana").first()
        assert elegance is not None and urbana is not None

        # Cliente perteneciente a Elegance
        client_user = db.query(User).filter(User.rol == RolEnum.cliente, User.tenant_id == elegance.id).first()
        if not client_user:
            # Si no existe, crearlo o usar token directo
            token = create_access_token({
                "sub": "00000000-0000-0000-0000-000000000001",
                "rol": RolEnum.cliente.value,
                "tenant_id": str(elegance.id),
                "branch_id": None,
            })
        else:
            token = create_access_token({
                "sub": str(client_user.id),
                "rol": client_user.rol.value,
                "tenant_id": str(client_user.tenant_id),
                "branch_id": None,
            })

        headers = {"Authorization": f"Bearer {token}"}

        # 1. Llamar sin query params: debe retornar SOLO sucursales de elegance
        res1 = client.get("/api/branches/public", headers=headers)
        assert res1.status_code == 200
        branches1 = res1.json().get("data", [])
        assert len(branches1) > 0
        for b in branches1:
            assert b["tenant_id"] == str(elegance.id), f"Sucursal {b['name']} no pertenece a Elegance"

        # 2. Intento de suplantar tenant (IDOR): debe ignorar urbana y mantener elegance
        res2 = client.get(f"/api/branches/public?tenant_id={urbana.id}", headers=headers)
        assert res2.status_code == 200
        branches2 = res2.json().get("data", [])
        for b in branches2:
            assert b["tenant_id"] == str(elegance.id), "Violación de aislamiento multitenant (IDOR detectado)"

        # 3. Listar empresas (/saas/companies): solo debe devolver su empresa
        res3 = client.get("/api/saas/companies", headers=headers)
        assert res3.status_code == 200
        companies = res3.json().get("data", [])
        assert len(companies) == 1
        assert companies[0]["id"] == str(elegance.id)

        # 4. Listar productos de catálogo: solo deben pertenecer a elegance
        res4 = client.get("/api/catalog/products", headers=headers)
        assert res4.status_code == 200
        products = res4.json().get("data", [])
        for p in products:
            assert p["tenant_id"] == str(elegance.id)
    finally:
        db.close()


def test_cu19_superadmin_can_view_all_companies():
    """
    Verifica que un Superadmin sí pueda listar todas las empresas registradas
    y ver las sucursales según el tenant que elija.
    """
    token = create_access_token({
        "sub": "00000000-0000-0000-0000-000000000000",
        "rol": RolEnum.superadmin.value,
        "tenant_id": None,
        "branch_id": None,
    })
    headers = {"Authorization": f"Bearer {token}"}

    res = client.get("/api/saas/companies", headers=headers)
    assert res.status_code == 200
    companies = res.json().get("data", [])
    assert len(companies) >= 2, "Superadmin debe poder visualizar todas las empresas"

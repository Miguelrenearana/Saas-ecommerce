from uuid import UUID
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.auth.dependencies import get_optional_current_payload
from app.core.database import get_db
from app.models.user import User
from app.schemas.enums import RolEnum
from app.packages.p0_saas_plataforma.schemas.company_schema import (
    CompanyCreate,
    CompanyUpdate,
    CompanyStatusUpdate,
    CompanyRead,
    CompanyOut,
)
from app.packages.p0_saas_plataforma.services.tenant_service import (
    create_tenant,
    get_company,
    get_company_by_subdomain,
    list_companies,
    update_company,
    set_company_status,
)
from app.utils.response import response

router = APIRouter(prefix="/saas/companies", tags=["SaaS Companies"])


@router.post("", summary="Registrar nueva empresa tenant (Superadmin)")
def register_company(data: CompanyCreate, db: Session = Depends(get_db)):
    company, admin_user = create_tenant(db, data)
    company_read = CompanyRead.model_validate(company)
    out = CompanyOut(
        company=company_read,
        initial_admin_id=admin_user.id if admin_user else None,
        initial_admin_email=admin_user.email if admin_user else None,
    )
    return response(
        status_code=status.HTTP_201_CREATED,
        message="Empresa registrada exitosamente con su plan inicial",
        data=out.model_dump(),
    )


@router.get("", summary="Listar empresas registradas con aislamiento multitenant")
def get_all_companies(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    status_filter: str | None = Query(None, alias="status"),
    db: Session = Depends(get_db),
    optional_user: dict | None = Depends(get_optional_current_payload),
):
    companies = list_companies(db, skip=skip, limit=limit, status_filter=status_filter)

    # Aislamiento multitenant estricto: si el actor no es superadmin, solo puede ver su tenant
    if optional_user:
        user_role = optional_user.get("rol")
        if user_role != RolEnum.superadmin.value:
            user_tenant_id = None
            tenant_id_str = optional_user.get("tenant_id")
            if tenant_id_str:
                try:
                    user_tenant_id = UUID(str(tenant_id_str))
                except (ValueError, TypeError):
                    user_tenant_id = None
            if user_tenant_id is None and optional_user.get("sub"):
                db_user = db.query(User).filter(User.id == UUID(str(optional_user["sub"]))).first()
                if db_user and db_user.tenant_id:
                    user_tenant_id = db_user.tenant_id

            if user_tenant_id:
                companies = [c for c in companies if c.id == user_tenant_id]

    data = [CompanyRead.model_validate(c).model_dump() for c in companies]
    return response(
        status_code=status.HTTP_200_OK,
        message="Empresas obtenidas correctamente",
        data=data,
    )


@router.get("/policies", summary="Consultar políticas comerciales y términos de la plataforma SaaS")
def get_saas_policies():
    import json
    from pathlib import Path
    data_dir = Path(__file__).resolve().parents[3] / "core" / "data"
    policies_file = data_dir / "policies.json"
    if not policies_file.exists():
        data_dir = Path(__file__).resolve().parents[2] / "core" / "data"
        policies_file = data_dir / "policies.json"
    with open(policies_file, encoding="utf-8") as f:
        policies_data = json.load(f)
    return response(
        status_code=status.HTTP_200_OK,
        message="Políticas comerciales y términos SaaS obtenidos correctamente",
        data=policies_data,
    )


@router.get("/subdomain/{subdomain}", summary="Resolver empresa por subdominio")
def get_by_subdomain(subdomain: str, db: Session = Depends(get_db)):
    company = get_company_by_subdomain(db, subdomain)
    return response(
        status_code=status.HTTP_200_OK,
        message="Empresa encontrada",
        data=CompanyRead.model_validate(company).model_dump(),
    )


@router.get("/{company_id}", summary="Obtener detalle de una empresa por ID")
def get_company_by_id(company_id: UUID, db: Session = Depends(get_db)):
    company = get_company(db, company_id)
    return response(
        status_code=status.HTTP_200_OK,
        message="Detalle de empresa obtenido",
        data=CompanyRead.model_validate(company).model_dump(),
    )


@router.put("/{company_id}", summary="Actualizar información general de una empresa")
def edit_company(company_id: UUID, update_data: CompanyUpdate, db: Session = Depends(get_db)):
    updated = update_company(db, company_id, update_data)
    return response(
        status_code=status.HTTP_200_OK,
        message="Empresa actualizada exitosamente",
        data=CompanyRead.model_validate(updated).model_dump(),
    )


@router.patch("/{company_id}/status", summary="Cambiar estado (ACTIVO / SUSPENDIDO) de una empresa")
def update_status(company_id: UUID, body: CompanyStatusUpdate, db: Session = Depends(get_db)):
    updated = set_company_status(db, company_id, body.status)
    return response(
        status_code=status.HTTP_200_OK,
        message=f"Estado de la empresa actualizado a {body.status}",
        data=CompanyRead.model_validate(updated).model_dump(),
    )

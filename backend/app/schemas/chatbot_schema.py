# Legacy compatibility shim - Canonical location: app.packages.p6_inteligencia_analitica.schemas.chatbot_schema
import sys
from app.packages.p6_inteligencia_analitica.schemas import chatbot_schema as _canonical

sys.modules[__name__] = _canonical

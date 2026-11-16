# Legacy compatibility shim - Canonical location: app.packages.p6_inteligencia_analitica.services.chatbot_service
import sys
from app.packages.p6_inteligencia_analitica.services import chatbot_service as _canonical

sys.modules[__name__] = _canonical

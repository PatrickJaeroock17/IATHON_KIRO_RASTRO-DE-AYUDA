# Rastro de Ayuda

Prototipo de trazabilidad de la ayuda humanitaria ante el Fenómeno El Niño (Piura), diseñado con **Kiro** (desarrollo guiado por especificaciones) sobre **AWS**. Proyecto del track *Ayuda trazable* de la Kiro IAthon, Lima 2026. Todos los datos son simulados.

> **Alcance de este repositorio.** Contiene la configuración de Kiro (steering, hooks, skill, prompts de los specs), la infraestructura base en AWS SAM, un esqueleto de API con pruebas y la documentación del producto. El código completo de los servicios (emparejamiento, Bedrock, SQS/SNS) se desarrolló dentro del entorno de Kiro de la hackatón y no se conserva aquí. Lo que se describe en "Diseño del producto" es lo que se especificó y se pidió construir a Kiro.

## El problema
En una emergencia, los albergues piden ayuda y los donantes ofrecen, pero nadie ve de punta a punta qué falta, dónde está, cuánto llegó realmente y qué quedó pendiente. Rastro de Ayuda no reemplaza a los sistemas oficiales (SINPAD, SIGBAH, SIGA): es una capa complementaria que relaciona lo pedido, lo enviado, lo recibido y lo pendiente. Detalle y fuentes en [`docs/propuesta-del-proyecto.pdf`](docs/propuesta-del-proyecto.pdf).

## Diseño del producto
1. **Necesidades en lenguaje cotidiano:** el coordinador escribe qué falta y Amazon Bedrock extrae ítem, cantidad, urgencia, lugar y región.
2. **Lotes y emparejamiento automático:** cada lote tiene almacén y vencimiento opcional. Una cola SQS dispara una Lambda que lo empareja con necesidades abiertas (primero las más urgentes y, entre lotes, el que vence antes) y SNS avisa de la asignación.
3. **Seguimiento hasta el uso:** línea de tiempo de cada lote (registrado, asignado, en tránsito, recibido y usado) y tablero por región. Si se despachan 40 cajas y llegan 35, el sistema registra 35 y deja 5 pendientes de conciliación; nunca marca todo como entregado.

Reglas de negocio pensadas para verificarse con pruebas basadas en propiedades (Hypothesis): recibido nunca mayor que enviado, un lote nunca se asigna por más de lo disponible y el emparejamiento es idempotente.

## Arquitectura objetivo
Interfaz web → API Gateway (HTTP API) → Lambda → DynamoDB, con Bedrock para interpretar texto, SQS para encolar y una Lambda que empareja con aviso por SNS. Tres capas estrictas (ver [`.kiro/steering/architecture.md`](.kiro/steering/architecture.md)): la interfaz solo habla con la API, las reglas viven en los servicios y solo los repositorios tocan DynamoDB.

## Qué hay en el repositorio
| Ruta | Contenido |
|---|---|
| `.kiro/steering/` | Reglas del proyecto para Kiro: producto, stack, arquitectura en capas, idioma y estilo |
| `.kiro/hooks/` | Hooks: revisar arquitectura al guardar, correr pruebas, escanear secretos y actualizar la bitácora de uso |
| `.kiro/skills/pitch-iathon/` | Skill que redacta el pitch a partir del spec y la bitácora |
| `.kiro/settings/mcp.json` | Configuración de MCP (servidor de documentación de AWS, desactivado por defecto) |
| `AGENTS.md` | Reglas de alcance, calidad y secretos que Kiro lee en cada petición |
| `docs/PROMPT_SPEC.md` | Prompts usados para generar los specs (contrato público y producto) |
| `docs/KIRO_USO.md` | Cómo se usó Kiro en el proyecto |
| `template.yaml` | Stack de AWS SAM base (tabla DynamoDB y Lambda de API) |
| `src/handlers/api.py`, `src/web/` | Esqueleto de API (`/health`, `/app`) y página inicial |
| `tests/` | Pruebas con pytest |
| `deploy.sh`, `deploy.ps1` | Compilan y despliegan con SAM |

## Probarlo
Requisitos: Python 3.12.

```bash
pip install -r requirements.txt
python -m pytest -q
```

Para desplegar el esqueleto hacen falta AWS CLI, SAM CLI y credenciales temporales en variables de entorno (nunca en archivos). Define `TEAM_ID` y, si usas Bedrock, `BEDROCK_MODEL_ID`, y ejecuta `./deploy.sh` (Mac/Linux) o `deploy.ps1` (Windows).

## Datos y privacidad
Solo datos simulados o públicos. No hay nombres, correos ni teléfonos reales y no se guardan cuentas de usuarios. Las credenciales de AWS no se escriben en el repositorio.

## Límites
Prototipo de hackatón. No está integrado con sistemas oficiales, no ofrece seguimiento GPS y las decisiones de asignación y confirmación quedan en manos de personas.

## Licencia
MIT

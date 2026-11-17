---
inclusion: always
---
# Stack, comandos y reglas de la entrega

## Stack
- Backend: AWS SAM (`template.yaml`) con Python 3.12 en Lambda detrás de API Gateway HTTP API. Todo el código vive en `src/`.
- Datos: DynamoDB, una tabla con claves `pk` y `sk` y facturación bajo demanda. Lo asíncrono usa SQS (con cola de mensajes fallidos) y SNS.
- IA: Amazon Bedrock con la API `converse` de boto3. El modelo sale de la variable de entorno `BEDROCK_MODEL_ID`; nunca se escribe a fuego.
- Frontend: HTML, CSS y JavaScript planos en un solo archivo, `src/web/index.html`, sin frameworks ni build. Lo sirve la misma API en `/app` y llama a la API con rutas relativas.
- Pruebas: pytest y Hypothesis, con repositorios y clientes falsos. No se prueba contra AWS real.
- Fuente de noticias: interfaz `NewsSource`, con datos de ejemplo del repositorio por defecto. La lectura en vivo de un RSS público está apagada (`NEWS_LIVE=0`) y solo se enciende si los organizadores lo permiten. No se conecta a X ni a otros servicios externos.
- Dependencias: solo `boto3`, que ya viene en el runtime de Lambda. No agregues librerías a `src/` sin avisarme.

## Reglas de la entrega (portal de la IAthon)
- El zip debe traer `.kiro/` (specs, steering y hooks), `template.yaml`, `src/`, `tests/` y `README.md`.
- `template.yaml` declara todos los servicios usados y define los Outputs `ApiUrl` y `WebUrl` (`ApiUrl` + `/app`, sin barra final). Mantén la API HTTP implícita (`ServerlessHttpApi`) que crean los eventos `HttpApi` de las funciones; si creas una explícita, actualiza los Outputs.
- `WebUrl` responde 200 con HTML, sin redirecciones y sin pedir login.
- Solo datos simulados o públicos; nunca nombres, correos ni teléfonos reales. No se conectan sistemas externos: solo nuestra cuenta de AWS.
- Insignias que debe cubrir el proyecto: API viva, persistencia (DynamoDB), asíncrono (SQS o SNS con Lambda), GenAI con propósito (Bedrock) y uso de Kiro.

## Contrato de las insignias (rutas públicas, sin autenticación, en la raíz de la API, no bajo /api)
- `GET /health` devuelve 200 con `{"status": "ok", "team": "<TeamId>"}`. El `TeamId` es un parámetro de `template.yaml` (variable `TEAM_ID`).
- `POST /items` con `{"value": "<texto>"}` devuelve 200 o 201 con `{"id": ...}`. `GET /items/{id}` devuelve `{"id", "value"}`. `GET /items` devuelve una lista de `{"id", "value"}` que incluye lo guardado (DynamoDB).
- `POST /jobs` con `{"input": "<texto>"}` responde 202 de inmediato con `{"jobId": ...}` y encola en SQS. Una Lambda trabajadora guarda `output` = el texto invertido. `GET /jobs/{jobId}` devuelve `{"status": "pending"}` y, antes de 12 segundos, `{"status": "done", "output": "<texto invertido>"}`.
- GenAI con propósito: Bedrock dentro de un flujo central (la extracción de necesidades), con prompts diseñados y manejo de errores.
- Maestría Kiro: en `.kiro/specs/<feature>/` deben estar `requirements.md`, `design.md` y `tasks.md`, cada uno con 300 caracteres o más de contenido propio; al menos un steering de 200 caracteres o más y un hook con `when` y `then`.

## Comandos
- Pruebas: `python -m pytest -q`
- Desplegar: `./deploy.ps1` (Windows) o `./deploy.sh`. Usa `sam build` y `sam deploy`. Las credenciales de AWS están en variables de entorno, nunca en archivos.
- Comprobar el frontend desplegado (igual que el agente evaluador): `curl -s -o /dev/null -w "%{http_code} %{content_type}" <WebUrl>` debe dar `200 text/html`.

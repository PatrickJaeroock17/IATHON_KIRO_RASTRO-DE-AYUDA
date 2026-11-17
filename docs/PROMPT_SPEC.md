# Orden de los specs

1. **Spec 0, contrato del portal (10 a 15 minutos):** da puntos de insignias desde el primer despliegue.
2. **Spec 1, el producto (más abajo):** necesidades, lotes y seguimiento.
3. **Spec 2, extra:** alertas de campo, solo si el núcleo está desplegado.

## Spec 0: contrato del portal

```text
Crea un spec llamado portal-contrato para las rutas públicas que verifica el portal de la IAthon: sin autenticación y en la raíz de la API (no bajo /api). Sigue la sección "Contrato de las insignias" de .kiro/steering/tech.md. 1) GET /health ya existe y devuelve status y team; mantenlo. 2) Persistencia en DynamoDB: POST /items con {"value": texto} devuelve 200 o 201 con {"id": ...}; GET /items/{id} devuelve {"id","value"}; GET /items devuelve un arreglo JSON de objetos {"id","value"} que incluye lo guardado. 3) Asíncrono con SQS: POST /jobs con {"input": texto} responde 202 de inmediato con {"jobId": ...} y encola un mensaje; una Lambda trabajadora lo procesa y guarda en DynamoDB output = el texto invertido (de atrás hacia adelante); GET /jobs/{jobId} devuelve {"status":"pending"} mientras no termine y {"status":"done","output": ...} al terminar, en menos de 12 segundos. Incluye una cola de fallidos. Declara todo en template.yaml, conservando los Outputs ApiUrl y WebUrl. 2 requisitos en EARS, máximo 4 tareas, pruebas con repositorios y colas falsas y una propiedad de prueba: invertir dos veces devuelve el texto original. Al terminar, despliega con deploy.ps1 y verifica cada ruta con curl.
```

Si "Verificar ahora" de Persistencia falla por el formato de `GET /items`, prueba devolver un objeto con la lista en la clave `items`.

---

## Spec 1: el producto (agente Spec, modo Requirements-first)

```text
Crea un spec para Rastro de Ayuda según .kiro/steering/product.md y architecture.md. Hazme antes las preguntas de aclaración que necesites. 3 requisitos en EARS, uno por función núcleo. Diseño en una página con diagrama Mermaid. Una tabla DynamoDB (pk, sk) con entidades NEED, LOT, MOV, EVT y WH, y 3 almacenes de ejemplo; rutas: POST /api/demo, POST y GET /api/needs, POST /api/lots, GET /api/lots/{code}, POST /api/movements/{id}/advance, POST /api/movements/{id}/receive, POST /api/movements/{id}/use y GET /api/board?region=. Cola SQS con cola de fallidos que dispara una Lambda matcher que procesa NEED_REGISTERED y LOT_REGISTERED: asigna por urgencia y, entre lotes, primero el que vence antes, con escritura condicional, y publica en SNS. Bedrock con la API converse extrae ítem, cantidad, urgencia, lugar y región de la necesidad (si el JSON es inválido, reintenta una vez y responde 422). Una recepción parcial registra lo recibido y abre una incidencia por la diferencia; nunca marca todo como entregado. Propiedades de prueba: recibido ≤ enviado; enviado = recibido + pendiente; nunca se asigna más de lo disponible ni de lo pedido; el matcher es idempotente; los eventos no se editan ni se borran. Máximo 6 tareas, la primera con las pruebas de propiedades. Agrega todo a template.yaml con los Outputs ApiUrl y WebUrl.
```

## Después de aprobar el spec
- Tras los requisitos: "Analiza los requisitos en busca de ambigüedades, conflictos y huecos. Dime qué encuentras antes de que los apruebe."
- Tras el diseño: "El diseño está bien. Crea las tareas, seis o menos. Cada tarea pequeña."

## Texto para registrar el frontend en el portal
- Flujo principal: 1. Escribir una necesidad y verla estructurada. 2. Registrar un lote y ver su asignación. 3. Confirmar una recepción parcial y ver la incidencia en la línea de tiempo.
- Funcionalidad GenAI: Bedrock convierte el texto libre de una necesidad en ítem, cantidad, urgencia y lugar; se prueba escribiendo una necesidad y viendo los campos extraídos.

## Spec secundario: alertas de campo (solo con el núcleo desplegado)
```text
Crea un spec secundario para alertas de campo en Rastro de Ayuda, según la sección "Extra" de .kiro/steering/product.md. Hay un cuadro para pegar una publicación o noticia y una lista de publicaciones de ejemplo marcadas como simuladas. Cada una va a una cola SQS; una Lambda usa Bedrock (API converse) para extraer tipo de evento, lugar, región, gravedad (1 a 3) y si hay una vía afectada. Una interfaz NewsSource devuelve noticias de ejemplo del repositorio (marcadas como simuladas); una implementación en vivo de RSS queda apagada con NEWS_LIVE=0. Si hay una noticia del mismo tipo y región en la ventana de tiempo, la alerta pasa de SIN_VERIFICAR a CORROBORADA; solo una persona puede pasarla a CONFIRMADA o DESCARTADA con un botón. Se publica en SNS. Un mapa muestra los puntos con color por gravedad y los lotes en tránsito de esa región se marcan "en riesgo de demora". No se guardan nombres ni cuentas de usuarios. Propiedades de prueba: la gravedad siempre está entre 1 y 3, la corroboración nunca confirma sola y el procesamiento es idempotente. Máximo 3 tareas.
```

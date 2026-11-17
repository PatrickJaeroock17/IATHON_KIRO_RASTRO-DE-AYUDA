---
inclusion: always
---
# Arquitectura: tres capas estrictas

- Capa 1, presentación: `src/web/index.html`. Solo habla con la API por HTTP.
- Capa 2, aplicación: los handlers de Lambda viven en `src/handlers` y solo validan la entrada y llaman al servicio. Las reglas de negocio viven en `src/services`.
- Capa 3, datos: `src/repositories` es el único código que toca DynamoDB.
- Los clientes de Bedrock, SQS y SNS viven en `src/clients`, detrás de una interfaz con una implementación falsa para las pruebas.
- Las dependencias (tabla, clientes) se reciben por parámetro, para poder probar con falsos.
- Un servicio no importa nada de `src/handlers`. Un repositorio no importa nada de `src/services`.
- Las reglas de negocio viven en un servicio, nunca en el handler, en la interfaz ni en el repositorio.
- Lo asíncrono usa un handler propio disparado por SQS (`src/handlers/matcher.py`) que procesa mensajes de necesidad registrada y de lote registrado. Debe ser idempotente: usa escrituras condicionales.
- Datos en una tabla DynamoDB con `pk` y `sk`. Entidades: NEED, LOT, MOV (movimiento), EVT (evento) y WH (almacén).
- Regla de trazabilidad: un lote cambia de estado solo agregando un evento a su historial. Los eventos no se editan ni se borran; una corrección es otro evento con motivo.
- Cantidades: recibido ≤ enviado, y enviado = recibido + pendiente de conciliación.
- Cada funcionalidad nueva sigue el camino: interfaz, handler, servicio, repositorio.
- Las noticias se leen por una interfaz `NewsSource` en `src/clients`, con una implementación de ejemplo (por defecto) y otra en vivo apagada con `NEWS_LIVE=0`. Bedrock no busca noticias: nuestro código las trae y las compara.
- Entidad ALERT en la tabla. Una alerta nunca pasa a CONFIRMADA sin una acción humana; la corroboración por noticias solo la marca como CORROBORADA.

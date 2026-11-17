---
inclusion: always
---
# Producto

- Nombre: Rastro de Ayuda
- Track: Ayuda trazable. Frente: solidaridad y ayuda humanitaria ante el Fenómeno El Niño (Piura).
- Problema: en una emergencia, los albergues piden ayuda y los donantes ofrecen, pero nadie ve de punta a punta qué falta, dónde está, cuánto llegó realmente y qué quedó pendiente.
- Posicionamiento: complemento de los sistemas oficiales (SINPAD, SIGBAH, SIGA), no un reemplazo. Su visión de crecimiento va del nivel local al nacional; el prototipo cubre una emergencia simulada en una región.
- Usuario principal: coordinadores de ayuda, responsables de almacén, albergues y donantes.
- Qué se entrega: registro de necesidades y donaciones con seguimiento hasta su uso.

## Funciones núcleo (solo 3)
1. Necesidad en lenguaje cotidiano: Bedrock extrae ítem, cantidad, urgencia, lugar y región, y se guarda.
2. Lote de donación y emparejamiento asíncrono: un lote tiene almacén y fecha de vencimiento opcional. Una cola SQS dispara una Lambda que lo empareja con necesidades abiertas (más urgentes primero; entre lotes, el que vence antes) y avisa por SNS.
3. Seguimiento hasta el uso: línea de tiempo del lote (registrado, asignado, en tránsito, recibido y usado). Si lo recibido es menor que lo enviado, se registra lo realmente recibido y se abre una incidencia por la diferencia, que queda pendiente de conciliación. Tablero por región.

## Flujo principal (para el portal, en 3 pasos)
1. Escribir una necesidad y verla estructurada.
2. Registrar un lote y ver su asignación.
3. Confirmar una recepción parcial y ver la incidencia en la línea de tiempo.

## Ejemplo clave para la demo
Se despachan 40 cajas y el destino confirma 35: el sistema registra 35 recibidas y deja 5 pendientes de conciliación. Nunca marca las 40 como entregadas.

## Reglas clave (pruebas de propiedades)
- Cantidad recibida ≤ cantidad enviada, y enviado = recibido + pendiente de conciliación.
- Una recepción parcial nunca marca todo como entregado.
- Un lote nunca se asigna por más de lo disponible, ni una necesidad recibe más de lo que pidió.
- El emparejamiento es idempotente: un mensaje repetido no asigna dos veces.
- Los estados avanzan solo en orden. Los eventos no se editan ni se borran; una corrección es otro evento con motivo.

## Datos de ejemplo
- Tres almacenes simulados en la región de Piura, cargados con un botón "Cargar datos de ejemplo" (`POST /api/demo`). Coordenadas aproximadas e inventadas, y la interfaz lo dice.
- Los lotes con vencimiento a 7 días o menos se marcan como "vence pronto" en el tablero.

## Extra: alertas de campo (solo después de desplegar el núcleo)
- Publicaciones de ejemplo, simuladas y marcadas como tales (no se usa la API real de X), más un cuadro para pegar una publicación o noticia.
- Cada una entra a una cola SQS. Una Lambda usa Bedrock para extraer tipo de evento, lugar, región, gravedad (1 a 3) y si hay una vía afectada. No se guardan nombres ni cuentas de usuarios.
- Estados: SIN_VERIFICAR, CORROBORADA (una noticia del mismo tipo y región, dentro de una ventana de tiempo, la respalda), y CONFIRMADA o DESCARTADA solo por una persona.
- Las noticias vienen de una fuente intercambiable: por defecto, un conjunto de noticias de ejemplo guardado en el repositorio y marcado como simulado. La lectura de un RSS público en vivo queda apagada (`NEWS_LIVE=0`) hasta que los organizadores confirmen que se permite.
- SNS publica la alerta, el mapa muestra los puntos por gravedad y los lotes en tránsito de esa región se marcan "en riesgo de demora".
- Reglas: la corroboración nunca confirma sola; la gravedad siempre está entre 1 y 3; el procesamiento es idempotente.

## Fuera de alcance
Autenticación y roles, pagos, fotos, QR, seguimiento GPS e integraciones reales con sistemas del Estado. El mapa y las alertas de campo son extras y solo se hacen si el núcleo ya está desplegado.

## Accesibilidad
Lenguaje simple, texto grande, alto contraste, usable desde el celular, etiquetas claras.

## Datos
Simulados, y la interfaz lo dice. Sin nombres, correos ni teléfonos reales.

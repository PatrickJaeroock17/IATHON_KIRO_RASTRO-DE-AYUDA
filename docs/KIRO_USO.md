# Cómo se usó Kiro

## Desarrollo guiado por especificaciones
El trabajo se planteó spec primero: los prompts para generar los specs están en [`PROMPT_SPEC.md`](PROMPT_SPEC.md).
- **Spec 0, contrato público:** rutas `/health`, `/items` y `/jobs` (persistencia en DynamoDB y trabajo asíncrono con SQS).
- **Spec 1, producto:** necesidades con Bedrock, lotes con emparejamiento asíncrono, seguimiento hasta el uso y tablero por región. Pedido en formato EARS (un requisito por función núcleo), diseño con diagrama Mermaid y un máximo de 6 tareas, la primera con las pruebas de propiedades.
- **Spec 2 (extra):** alertas de campo, solo si el núcleo estaba desplegado.

## Steering y AGENTS.md
- `AGENTS.md`: alcance mínimo, calidad (pruebas por regla de negocio) y prohibición de escribir secretos.
- `.kiro/steering/product.md`: problema, usuario, tres funciones núcleo y reglas clave para las pruebas.
- `.kiro/steering/tech.md`: stack (SAM, Python 3.12, DynamoDB, SQS/SNS, Bedrock `converse`), comandos y contrato de rutas.
- `.kiro/steering/architecture.md`: tres capas estrictas (interfaz, servicios, repositorios).
- `.kiro/steering/comunicacion.md` y `style.md`: idioma y estilo visual.

## Hooks
- **Revisar arquitectura al guardar** (automático): compara cada archivo de `src/` con las reglas de capas.
- **Escanear secretos**, **Correr pruebas** y **Actualizar bitácora de uso de Kiro** (manuales).

## Skill y MCP
- Skill `pitch-iathon`: redacta el pitch a partir del spec y de esta bitácora.
- MCP de documentación de AWS configurado en `.kiro/settings/mcp.json` (desactivado por defecto).

## Pruebas
Las pruebas de este repositorio cubren el esqueleto de la API (`tests/test_smoke.py`). Las pruebas basadas en propiedades de las reglas de negocio se definieron en el spec y se generaron en el entorno de Kiro de la hackatón.

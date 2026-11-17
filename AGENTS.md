# Reglas del proyecto

Este archivo lo lee Kiro en cada petición. Mantenlo corto.

## Alcance
- Construye lo mínimo que cumpla el spec: sin autenticación, sin Docker y sin dependencias de más.
- El stack, los comandos y las reglas de la entrega están en `.kiro/steering/tech.md`. Las reglas del producto, en `product.md`. Si algo choca, pregúntame antes de seguir.
- El idioma y el tono están en `.kiro/steering/comunicacion.md`.

## Calidad
- Cada regla de negocio y cada handler nuevo trae al menos una prueba en `tests/`.
- Las reglas con entradas variables (cantidades, estados, asignaciones) llevan además una prueba basada en propiedades con Hypothesis.
- Después de implementar una tarea, corre `python -m pytest -q` y corrige lo que falle. Tras cambiar `template.yaml`, valida que sea coherente con el código.
- Nunca escribas claves, tokens ni credenciales en el código, en `template.yaml` ni en los archivos de steering.

## Datos
- Los datos de ejemplo son inventados y la interfaz lo indica. Nunca uses nombres, correos ni teléfonos reales.

## Al terminar un turno
- Resume en 5 líneas o menos qué cambió y qué falta.

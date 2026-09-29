# Integrantes: [Nombre 1], [Nombre 2], [Nombre 3]
#
# En la misma carpeta deben estar:
#   principal.exs, datos.exs, validacion.exs, liquidacion.exs, ranking.exs,
#   analisis.exs, entrada.exs, reportes.exs, comprobante.exs,
#   investigacion.exs, mediciones.exs, mensajeria.exs,
#   Elixir.Util.beam y Elixir.Util2.beam
#
# Para ejecutar (todo en una sola línea):
#
#   elixir -r datos.exs -r validacion.exs -r liquidacion.exs -r ranking.exs -r analisis.exs -r entrada.exs -r reportes.exs -r comprobante.exs -r investigacion.exs -r mediciones.exs -r mensajeria.exs principal.exs
#
# ---------------------------------------------------------------------------
# ABSTRACCIÓN
#   ¿Qué se solicita?  Validar los servicios, liquidar a cada repartidor,
#                      mostrar los reportes R1 a R8 y el comprobante de un repartidor.
#   ¿Qué información es relevante?  Repartidores, zonas, servicios (con posibles
#                      errores), parámetros de negocio y un servicio adicional opcional.
#
# DESCOMPOSICIÓN
#   - Validar los servicios (válidos / rechazados)          -> módulo Validacion
#   - Calcular valor, bonificación, alquiler y neto          -> módulo Liquidacion
#   - Ordenar listas de forma configurable                   -> módulo Ranking
#   - Calcular lo que necesitan los reportes R2 a R8          -> módulo Analisis
#   - Ingresar y validar el servicio adicional                -> módulo Entrada
#   - Armar el texto de los reportes R1 a R8                  -> módulo Reportes
#   - Armar el comprobante de un repartidor                   -> módulo Comprobante
#   - Combinar los km propios con los de la empresa aliada    -> módulo Investigacion
#   - Medir tiempos con :timer.tc/1                           -> módulo Mediciones
#   - Orquestar todo lo anterior (el "main")                  -> módulo Mensajeria
#
# RECONOCIMIENTO DE PATRONES (funciones de Util2)
#   - Util2.ingresar/2                     leer un texto del teclado
#   - Util2.mostrar/2                      mostrar un mensaje
#   - Util2.ordenar/3                      ordenar una colección
#   - Util2.convertir_coleccion_mensaje/2  convertir una colección en líneas de texto
# ---------------------------------------------------------------------------

Mensajeria.main()

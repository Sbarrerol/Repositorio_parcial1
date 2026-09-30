# Integrantes: [Nombre 1], [Nombre 2], [Nombre 3]
#
# En la misma carpeta deben estar:
#   principal.exs, datos.exs, validacion.exs, liquidacion.exs, ranking.exs,
#   analisis.exs, entrada.exs, reportes.exs, comprobante.exs,
#   investigacion.exs, mediciones.exs, mensajeria.exs,
#   Elixir.Util.beam y Elixir.Util2.beam
#
# Para ejecutar, parado en esa misma carpeta:
#
#   elixir principal.exs
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

# Carga cada módulo desde su propio archivo, en el orden en que se necesitan.
Code.require_file("datos.exs")
Code.require_file("validacion.exs")
Code.require_file("liquidacion.exs")
Code.require_file("ranking.exs")
Code.require_file("analisis.exs")
Code.require_file("entrada.exs")
Code.require_file("reportes.exs")
Code.require_file("comprobante.exs")
Code.require_file("investigacion.exs")
Code.require_file("mediciones.exs")
Code.require_file("mensajeria.exs")

Mensajeria.main()

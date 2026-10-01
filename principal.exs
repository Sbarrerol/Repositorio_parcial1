# Integrantes: [Sofia Aviles Diaz], [Santiago Barrero Lopez], [Yvette Daniela Campo Osorio]
#
#
# Para ejecutar, parado en esa misma carpeta:
#
#   elixir principal.exs
# Ejecutar:
#         elixir -r datos.exs -r validacion.exs -r liquidacion.exs -r ranking.exs -r analisis.exs -r entrada.exs -r 
#         reportes.exs -r comprobante.exs -r investigacion.exs -r mediciones.exs -r mensajeria.exs principal.exs
# ---------------------------------------------------------------------------
# ABSTRACCIÓN
#   ¿Qué se solicita?   Se solicita crear un programa que valide los servicios de una empresa de mensajería,
#           calcule el pago semanal de sus repartidores y genere los resportes solicitados. También debe permitir 
#           ingresar un servicio adicional y generar un comprobante de pago para un repartidor.
#   ¿Qué información es relevante?  La información releante son los datos de los respartidores, las zonas, y los servicios.
#           También son impostantes los kilómetros recorridos, los retrasos, los días trabajados,el uso de bicicleta y los
#           parámetros económicos establecidos por la empresa, ya que estos datos permiten validar los servicios, Calcular
#           bonificaciones, descuentos, alquileres y el pago final.
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
#   - Util2.ingresar/2                     leer los datos ingresados por el usuario, como el servicio adicional y código del repartidor
#   - Util2.mostrar/2                      mostrar información al usuario,como los resportes, mensajes de validación y comprobantes.
#   - Util2.ordenar/3                      ordenar una colección, por ejemplo, los repartidores por el valor neto de mayor  a menor.
#   - Util2.convertir_coleccion_mensaje/2  convertir las colecciones de resultados en texto para poder msotrarlas en los resportes.
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

# Integrantes: [Sofia Aviles Diaz], [Santiafo Barrero Lopez], [Yvette Daniela Campo Osorio]

defmodule Mensajeria do
  def main do
    repartidores = Datos.repartidores()
    zonas = Datos.zonas()
    servicios = Datos.servicios()

    # 1. Validar los servicios de los datos
    {validos, rechazados} = Validacion.clasificar(servicios, repartidores, zonas)

    # 2. Servicio adicional
    adicional = Entrada.solicitar_servicio()

    {validos, rechazados, aviso} =
      Entrada.incorporar(adicional, validos, rechazados, repartidores, zonas)

    Util2.mostrar("\n" <> aviso <> "\n", :mensaje)

    # 3. Liquidar
    liquidaciones = Liquidacion.liquidar_todos(repartidores, validos)

    # 4. Reportes (se mide cuánto tardan en generarse)
    {microsegundos, reportes} =
      :timer.tc(fn -> Reportes.todos(validos, rechazados, repartidores, zonas, liquidaciones) end)

    Enum.each(reportes, fn reporte -> Util2.mostrar(reporte, :mensaje) end)

    # 5. Comprobante de un repartidor
    comprobante =
      "Ingrese el código de un repartidor para ver su comprobante: "
      |> Util2.ingresar(:texto)
      |> Comprobante.mensaje(liquidaciones)

    Util2.mostrar("\n" <> comprobante, :mensaje)

    # 6. Investigación y mediciones
    investigacion = validos |> Analisis.kilometros_por_dia() |> Investigacion.reporte()
    Util2.mostrar("\n" <> investigacion, :mensaje)

    mediciones = Mediciones.reporte(servicios, repartidores, zonas, validos, microsegundos)
    Util2.mostrar("\n" <> mediciones, :mensaje)
  end
end

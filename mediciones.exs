# Integrantes: [Nombre 1], [Nombre 2], [Nombre 3]

defmodule Mediciones do
  @repeticiones 1000

  def reporte(servicios, repartidores, zonas, validos, microsegundos_reportes) do
    ms_validar =
      medir(fn -> Validacion.clasificar(servicios, repartidores, zonas) end)

    ms_liquidar =
      medir(fn -> Liquidacion.liquidar_todos(repartidores, validos) end)

    "=== Mediciones con :timer.tc/1 ===\n" <>
      " Generar los 8 reportes (1 vez): #{ms(microsegundos_reportes)} ms\n" <>
      " Validar todos los servicios (#{@repeticiones} veces): #{ms_validar} ms\n" <>
      " Liquidar a todos los repartidores (#{@repeticiones} veces): #{ms_liquidar} ms\n"
  end

  # Ejecuta la función muchas veces y devuelve los milisegundos que tardó
  defp medir(funcion) do
    {microsegundos, _resultado} =
      :timer.tc(fn -> Enum.each(1..@repeticiones, fn _ -> funcion.() end) end)

    ms(microsegundos)
  end

  defp ms(microsegundos), do: Liquidacion.redondear(microsegundos / 1000)
end

# Integrantes: [Sofia Aviles Diaz], [Santiago Barrero Lopez], [Yvette Daniela Campo Osorio]

defmodule Comprobante do
  # Recibe el código escrito y las liquidaciones. Siempre devuelve un texto.
  def mensaje(codigo, liquidaciones) do
    encontrada =
      Enum.find(liquidaciones, fn l -> String.upcase(l.codigo) == String.upcase(codigo) end)

    case encontrada do
      nil -> "No existe ningún repartidor con el código \"#{codigo}\"."
      liquidacion -> generar(liquidacion)
    end
  end

  defp generar(l) do
    "=== Comprobante de pago ===\n" <>
      "Repartidor: #{l.nombre} (#{l.codigo})\n\n" <>
      "Detalle por día:\n" <>
      detalle_dias(l.dias) <>
      "\nSuma del valor de servicios: $#{dos(l.valor_servicios)}\n" <>
      "Suma de bonificaciones: $#{dos(l.bonificaciones)}\n" <>
      "Descuento por alquiler de bicicleta: $#{dos(l.alquiler)}\n" <>
      "NETO A PAGAR: $#{dos(l.neto)}\n"
  end

  defp detalle_dias(dias) do
    if dias == [] do
      "  (sin servicios válidos: no hay días trabajados)\n"
    else
      dias
      |> Util2.convertir_coleccion_mensaje(fn d ->
        "  Día #{d.dia} | #{dos(d.kilometros)} km | servicios: $#{dos(d.valor_servicios)}" <>
          " | bonificación: $#{dos(d.bonificacion)}\n"
      end)
      |> Enum.join()
    end
  end

  defp dos(numero), do: Liquidacion.redondear(numero)
end

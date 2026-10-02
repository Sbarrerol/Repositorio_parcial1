# Integrantes: [Sofia Aviles Diaz], [Santiago Barrero Lopez], [Yvette Daniela Campo Osorio]

defmodule Comprobante do
  @moduledoc """
  Genera comprobantes de pago para los repartidores a partir de sus
  liquidaciones semanales.

  El módulo permite consultar una liquidación mediante el código del
  repartidor y construir un comprobante que muestra el detalle de los
  días trabajados, los kilómetros recorridos, el valor de los servicios,
  las bonificaciones, el descuento por alquiler y el valor neto a pagar.

  ## Funciones principales

  - `mensaje/2`: busca la liquidación correspondiente a un código y
    genera el comprobante de pago.

  ## Funciones privadas

  - `generar/1`: construye el texto completo del comprobante a partir
    de una liquidación.
  - `detalle_dias/1`: genera el detalle de los días trabajados.
  - `dos/1`: redondea los valores numéricos antes de mostrarlos.

  ## Información

  - **Proyecto:** Sistema de gestión y liquidación de servicios de mensajería
  - **Asignatura:** Programación 3
  - **Universidad:** Universidad del Quindío
  - **Periodo:** 2026-2
  """

  @doc """
  Busca la liquidación de un repartidor mediante su código y genera
  un comprobante de pago.

  La búsqueda se realiza sin distinguir entre mayúsculas y minúsculas,
  por lo que códigos como `"M01"` y `"m01"` son considerados equivalentes.

  ## Parámetros

  - `codigo`: código del repartidor que se desea consultar.
  - `liquidaciones`: lista de liquidaciones generadas para los repartidores.

  ## Retorno

  Si encuentra una liquidación con el código indicado, devuelve un texto
  con el comprobante de pago.

  Si no encuentra el código, devuelve un mensaje indicando que no existe
  ningún repartidor con ese código.

  ## Ejemplos

      Comprobante.mensaje("M01", liquidaciones)

  También permite consultar utilizando minúsculas:

      Comprobante.mensaje("m01", liquidaciones)
  """
  def mensaje(codigo, liquidaciones) do
    encontrada =
      Enum.find(liquidaciones, fn l -> String.upcase(l.codigo) == String.upcase(codigo) end)

    case encontrada do
      nil -> "No existe ningún repartidor con el código \"#{codigo}\"."
      liquidacion -> generar(liquidacion)
    end
  end

  # -----------------------------------
  # Funciones auxiliares privadas
  # -----------------------------------

  # Construye el texto completo del comprobante utilizando la información
  # contenida en una liquidación.
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

  # Genera una línea de texto para cada día trabajado.
  # Si no existen días con servicios válidos, muestra un mensaje indicando
  # que no hay días trabajados.
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

  # Redondea un valor numérico utilizando la función de redondeo
  # definida en el módulo Liquidacion.
  defp dos(numero), do: Liquidacion.redondear(numero)
end

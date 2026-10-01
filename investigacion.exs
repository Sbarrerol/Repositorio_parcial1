# Integrantes: [Sofia Aviles Diaz], [Santiafo Barrero Lopez], [Yvette Daniela Campo Osorio]

defmodule Investigacion do
  def empresa_aliada do
    %{1 => 580.5, 2 => 430, 3 => 510, 5 => 625, 7 => 180}
  end

  # Map.merge/3: si el día está en los dos mapas, la función suma los kilómetros.
  # Los días que están en un solo mapa se dejan igual.
  def combinar(propios, aliada) do
    Map.merge(propios, aliada, fn _dia, km_propios, km_aliada -> km_propios + km_aliada end)
  end

  def reporte(km_dias) do
    aliada = empresa_aliada()

    "=== Investigación: Map.merge/3 ===\n" <>
      " Kilómetros propios (R3): #{mostrar(km_dias)}\n" <>
      " Kilómetros empresa aliada: #{mostrar(aliada)}\n" <>
      " Map.merge/3 (suma): #{mostrar(combinar(km_dias, aliada))}\n" <>
      " Map.merge/2 (el aliado reemplaza): #{mostrar(Map.merge(km_dias, aliada))}\n"
  end

  # Redondea los valores del mapa para que se vea ordenado
  defp mostrar(mapa) do
    redondeado = for {dia, km} <- mapa, into: %{}, do: {dia, Liquidacion.redondear(km)}
    inspect(redondeado)
  end
end

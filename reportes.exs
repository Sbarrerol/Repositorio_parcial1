# Integrantes: [Sofia Aviles Diaz], [Santiago Barrero Lopez], [Yvette Daniela Campo Osorio]

defmodule Reportes do
  @motivos [
    :repartidor_desconocido,
    :zona_desconocida,
    :dia_invalido,
    :kilometros_fuera_de_rango,
    :retraso_invalido
  ]

  # Devuelve una lista con los 8 reportes, en orden
  def todos(validos, rechazados, repartidores, zonas, liquidaciones) do
    lideres = Analisis.lideres_por_dia(validos, repartidores)

    [
      r1(rechazados),
      r2(Analisis.kilometros_por_zona(validos, zonas)),
      r3(Analisis.kilometros_por_dia(validos)),
      r4(liquidaciones),
      r5(lideres, Analisis.mas_dias_primer_lugar(lideres, repartidores)),
      r6(Analisis.puntualidad(validos, repartidores)),
      r7(Analisis.costo_semanal(liquidaciones)),
      r8(Analisis.repartidores_en_todas_las_zonas(validos, repartidores, zonas))
    ]
  end

  def r1(rechazados) do
    detalle =
      rechazados
      |> Enum.with_index(1)
      |> lineas(fn {{servicio, motivo}, numero} -> " #{numero}. #{motivo} -> #{inspect(servicio)}\n" end)

    cantidades =
      lineas(@motivos, fn motivo ->
        cantidad = Enum.count(rechazados, fn {_servicio, m} -> m == motivo end)
        " - #{motivo}: #{cantidad}\n"
      end)

    "=== R1. Servicios rechazados ===\n" <> detalle <> "\nCantidad de rechazos por motivo:\n" <> cantidades
  end

  def r2(zonas_km) do
    filas =
      zonas_km
      |> Ranking.ranking(campo: fn zona -> zona.densidad end, sentido: :desc)
      |> Enum.with_index(1)
      |> lineas(fn {zona, numero} ->
        " #{numero}. #{zona.nombre}: #{dos(zona.kilometros)} km | área #{zona.area} km² | densidad #{dos(zona.densidad)}\n"
      end)

    "=== R2. Kilómetros y densidad por zona (mayor a menor densidad) ===\n" <> filas
  end

  def r3(km_dias) do
    dias = Enum.sort(km_dias)

    filas =
      lineas(dias, fn {dia, km} ->
        " Día #{dia}: #{dos(km)} km | meta alcanzada: #{si_no(Analisis.meta_alcanzada?(km))}\n"
      end)

    todos = Enum.all?(dias, fn {_dia, km} -> Analisis.meta_alcanzada?(km) end)
    alguno = Enum.any?(dias, fn {_dia, km} -> Analisis.meta_alcanzada?(km) end)

    "=== R3. Kilómetros de la empresa por día (meta #{Analisis.meta_diaria()} km) ===\n" <>
      filas <>
      "\n¿Se alcanzó la meta todos los días? #{si_no(todos)}\n" <>
      "¿Se alcanzó la meta al menos un día? #{si_no(alguno)}\n"
  end

  def r4(liquidaciones) do
    filas =
      liquidaciones
      |> Ranking.ranking(campo: fn l -> l.neto end, sentido: :desc)
      |> Enum.with_index(1)
      |> lineas(fn {l, numero} ->
        " #{numero}. #{l.codigo} #{l.nombre} | km: #{dos(l.kilometros)}" <>
          " | servicios: $#{dos(l.valor_servicios)}" <>
          " | bonificaciones: $#{dos(l.bonificaciones)}" <>
          " | alquiler: $#{dos(l.alquiler)}" <>
          " | NETO: $#{dos(l.neto)}\n"
      end)

    "=== R4. Liquidación semanal (ordenada por neto, de mayor a menor) ===\n" <> filas
  end

  def r5(lideres_dia, {veces, ganadores}) do
    filas =
      lineas(lideres_dia, fn dia ->
        if dia.lideres == [] do
          " Día #{dia.dia}: sin servicios válidos\n"
        else
          " Día #{dia.dia}: #{nombres(dia.lideres)} (#{dos(dia.kilometros)} km)\n"
        end
      end)

    final =
      if veces == 0 do
        "\nNingún repartidor tiene servicios válidos.\n"
      else
        "\nPrimer lugar en más días: #{nombres(ganadores)} con #{veces} día(s).\n"
      end

    "=== R5. Repartidor con más kilómetros cada día ===\n" <> filas <> final
  end

  def r6(puntuales) do
    if puntuales == [] do
      "=== R6. Mejor puntualidad ===\nNingún repartidor tiene al menos 3 servicios válidos.\n"
    else
      ordenados = Ranking.ranking(puntuales, campo: fn p -> p.ponderado end, sentido: :asc)

      filas =
        ordenados
        |> Enum.with_index(1)
        |> lineas(fn {p, numero} ->
          " #{numero}. #{p.codigo} #{p.nombre} | #{p.servicios} servicios" <>
            " | ponderado: #{dos(p.ponderado)} min | promedio simple: #{dos(p.simple)} min\n"
        end)

      mejor = hd(ordenados)

      "=== R6. Mejor puntualidad (mínimo 3 servicios válidos; menor retraso ponderado) ===\n" <>
        filas <>
        "\nMejor puntualidad: #{mejor.nombre} (#{mejor.codigo}) con #{dos(mejor.ponderado)} min.\n"
    end
  end

  def r7({:ok, datos}) do
    "=== R7. Total pagado y costo por kilómetro ===\n" <>
      " Total pagado a los repartidores (suma de netos): $#{dos(datos.total)}\n" <>
      " Kilómetros válidos de la semana: #{dos(datos.kilometros)} km\n" <>
      " Costo promedio pagado por kilómetro: $#{dos(datos.por_kilometro)}\n"
  end

  def r7({:error, :sin_kilometros}) do
    "=== R7. Total pagado y costo por kilómetro ===\nNo hay kilómetros válidos.\n"
  end

  def r8(repartidores) do
    filas = lineas(repartidores, fn r -> " - #{r.nombre} (#{r.codigo})\n" end)

    if repartidores == [] do
      "=== R8. Repartidores con servicios en todas las zonas ===\nNingún repartidor cumple la condición.\n"
    else
      "=== R8. Repartidores con servicios en todas las zonas ===\n" <> filas
    end
  end

  # Convierte una colección en un solo texto, una línea por elemento
  defp lineas(coleccion, formato) do
    coleccion
    |> Util2.convertir_coleccion_mensaje(formato)
    |> Enum.join()
  end

  # Ejemplo: [%{nombre: "Ana", codigo: "M01"}] -> "Ana (M01)"
  defp nombres(lista) do
    lista
    |> Enum.map(fn elemento -> "#{elemento.nombre} (#{elemento.codigo})" end)
    |> Enum.join(", ")
  end

  defp dos(numero), do: Liquidacion.redondear(numero)

  defp si_no(true), do: "sí"
  defp si_no(false), do: "no"
end

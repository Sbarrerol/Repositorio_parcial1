# Integrantes: [Nombre 1], [Nombre 2], [Nombre 3]

defmodule Analisis do
  @meta_diaria 500
  @servicios_minimos 3

  def meta_diaria, do: @meta_diaria

  def meta_alcanzada?(kilometros), do: kilometros >= @meta_diaria

  # R2: kilómetros, área y densidad de cada zona (incluidas las que no tienen servicios)
  def kilometros_por_zona(validos, zonas) do
    for zona <- zonas do
      de_la_zona = Enum.filter(validos, fn servicio -> servicio.zona == zona.id end)
      kilometros = Liquidacion.redondear(sumar_km(de_la_zona))

      %{
        nombre: zona.nombre,
        area: zona.area,
        kilometros: kilometros,
        densidad: kilometros / zona.area
      }
    end
  end

  # R3: mapa %{dia => kilómetros de toda la empresa}
  def kilometros_por_dia(validos) do
    for dia <- Validacion.dias(), into: %{} do
      del_dia = Enum.filter(validos, fn servicio -> servicio.dia == dia end)
      {dia, Liquidacion.redondear(sumar_km(del_dia))}
    end
  end

  # R5: para cada día, los repartidores con más kilómetros (todos si hay empate)
  def lideres_por_dia(validos, repartidores) do
    for dia <- Validacion.dias() do
      del_dia = Enum.filter(validos, fn servicio -> servicio.dia == dia end)

      totales =
        for repartidor <- repartidores do
          de_el = Enum.filter(del_dia, fn servicio -> servicio.repartidor == repartidor.codigo end)

          %{
            codigo: repartidor.codigo,
            nombre: repartidor.nombre,
            kilometros: Liquidacion.redondear(sumar_km(de_el))
          }
        end

      mejor = Enum.max_by(totales, fn total -> total.kilometros end)
      maximo = mejor.kilometros

      lideres =
        if maximo > 0 do
          Enum.filter(totales, fn total -> total.kilometros == maximo end)
        else
          []
        end

      %{dia: dia, kilometros: maximo, lideres: lideres}
    end
  end

  # R5: quién(es) ocupó el primer lugar en más días. Devuelve {veces, ganadores}
  def mas_dias_primer_lugar(lideres_dia, repartidores) do
    conteos =
      for repartidor <- repartidores do
        veces =
          Enum.count(lideres_dia, fn dia ->
            Enum.any?(dia.lideres, fn lider -> lider.codigo == repartidor.codigo end)
          end)

        %{codigo: repartidor.codigo, nombre: repartidor.nombre, veces: veces}
      end

    mejor = Enum.max_by(conteos, fn conteo -> conteo.veces end)
    ganadores = Enum.filter(conteos, fn conteo -> conteo.veces == mejor.veces end)

    {mejor.veces, ganadores}
  end

  # R6: retraso ponderado y promedio simple de quienes tienen 3 o más servicios válidos
  #   ponderado = suma(retraso x kilómetros) / suma(kilómetros)
  def puntualidad(validos, repartidores) do
    elegibles =
      Enum.filter(repartidores, fn repartidor ->
        length(servicios_de(validos, repartidor)) >= @servicios_minimos
      end)

    for repartidor <- elegibles do
      mios = servicios_de(validos, repartidor)

      suma_retraso_por_km = Enum.sum(Enum.map(mios, fn s -> s.retraso * s.kilometros end))
      suma_km = sumar_km(mios)
      suma_retrasos = Enum.sum(Enum.map(mios, fn s -> s.retraso end))

      %{
        codigo: repartidor.codigo,
        nombre: repartidor.nombre,
        servicios: length(mios),
        ponderado: suma_retraso_por_km / suma_km,
        simple: suma_retrasos / length(mios)
      }
    end
  end

  # R7: total pagado (suma de los netos) y costo por kilómetro
  def costo_semanal(liquidaciones) do
    total = Enum.sum(Enum.map(liquidaciones, fn l -> l.neto end))
    kilometros = Enum.sum(Enum.map(liquidaciones, fn l -> l.kilometros end))

    if kilometros > 0 do
      {:ok, %{total: total, kilometros: kilometros, por_kilometro: total / kilometros}}
    else
      {:error, :sin_kilometros}
    end
  end

  # R8: repartidores con al menos un servicio válido en TODAS las zonas
  def repartidores_en_todas_las_zonas(validos, repartidores, zonas) do
    Enum.filter(repartidores, fn repartidor ->
      Enum.all?(zonas, fn zona ->
        Enum.any?(validos, fn servicio ->
          servicio.repartidor == repartidor.codigo and servicio.zona == zona.id
        end)
      end)
    end)
  end

  defp servicios_de(validos, repartidor) do
    Enum.filter(validos, fn servicio -> servicio.repartidor == repartidor.codigo end)
  end

  defp sumar_km(servicios) do
    Enum.sum(Enum.map(servicios, fn servicio -> servicio.kilometros end))
  end
end

# Integrantes: [Sofia Aviles Diaz], [Santiago Barrero Lopez], [Yvette Daniela Campo Osorio]

# Integrantes: [Sofia Aviles Diaz], [Santiafo Barrero Lopez], [Yvette Daniela Campo Osorio]
>>>>>>> 7b08c75 (Documentar módulo y funciones de Analisis)

defmodule Analisis do
  @moduledoc """
  Funciones de análisis de los servicios de la empresa de mensajería.

  El módulo contiene las operaciones necesarias para calcular los datos
  utilizados en los reportes R2, R3, R5, R6, R7 y R8.

  Entre sus funciones se encuentran:

  - calcular kilómetros y densidad por zona;
  - calcular kilómetros recorridos por día;
  - determinar los líderes de kilómetros por día;
  - determinar quiénes ocuparon el primer lugar durante más días;
  - analizar la puntualidad de los repartidores;
  - calcular el costo semanal y el costo por kilómetro;
  - identificar repartidores con servicios en todas las zonas.
  """

  @meta_diaria 500
  @servicios_minimos 3

    @doc """
  Retorna la meta diaria de kilómetros establecida para la empresa.

  ## Retorna

  El valor de la meta diaria, establecido en `500` kilómetros.

  ## Ejemplo

      Analisis.meta_diaria()
      # 500
  """
  def meta_diaria, do: @meta_diaria

  @doc """
  Determina si se alcanzó la meta diaria de kilómetros.

  ## Parámetros

  - `kilometros`: cantidad de kilómetros recorridos durante el día.

  ## Retorna

  `true` si los kilómetros son mayores o iguales a la meta diaria;
  `false` en caso contrario.

  ## Ejemplos

      Analisis.meta_alcanzada?(500)
      # true

      Analisis.meta_alcanzada?(450)
      # false
  """
  def meta_alcanzada?(kilometros), do: kilometros >= @meta_diaria

  @doc """
  Calcula los kilómetros y la densidad de cada zona.

  Incluye todas las zonas recibidas, incluso aquellas que no tienen
  servicios válidos.

  ## Parámetros

  - `validos`: lista de servicios válidos.
  - `zonas`: lista de zonas de la empresa.

  ## Retorna

  Una lista de mapas con el nombre de la zona, su área, los kilómetros
  recorridos y la densidad de kilómetros por área.

  El resultado es utilizado principalmente para generar el reporte R2.
  """
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

  @doc """
  Calcula los kilómetros totales recorridos por la empresa en cada día.

  ## Parámetros

  - `validos`: lista de servicios válidos.

  ## Retorna

  Un mapa donde cada clave corresponde a un día y su valor corresponde
  a los kilómetros recorridos durante ese día.

  Se incluyen todos los días definidos por `Validacion.dias()`.

  Este resultado se utiliza para generar el reporte R3.
  """
  # R3: mapa %{dia => kilómetros de toda la empresa}
  def kilometros_por_dia(validos) do
    for dia <- Validacion.dias(), into: %{} do
      del_dia = Enum.filter(validos, fn servicio -> servicio.dia == dia end)
      {dia, Liquidacion.redondear(sumar_km(del_dia))}
    end
  end

  @doc """
  Determina los repartidores con mayor cantidad de kilómetros en cada día.

  En caso de empate, se incluyen todos los repartidores que tengan
  la misma cantidad máxima de kilómetros.

  ## Parámetros

  - `validos`: lista de servicios válidos.
  - `repartidores`: lista de repartidores registrados.

  ## Retorna

  Una lista con un elemento por cada día. Cada elemento contiene el día,
  los kilómetros máximos y la lista de repartidores líderes.

  Este resultado se utiliza para generar el reporte R5.
  """
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

  @doc """
  Determina qué repartidores ocuparon el primer lugar en más días.

  Cuenta la cantidad de días en los que cada repartidor aparece entre
  los líderes y devuelve todos los repartidores que tengan la cantidad
  máxima de primeros lugares.

  ## Parámetros

  - `lideres_dia`: resultado obtenido mediante `lideres_por_dia/2`.
  - `repartidores`: lista de repartidores registrados.

  ## Retorna

  Una tupla con dos elementos:

  - la cantidad máxima de días en primer lugar;
  - la lista de repartidores que alcanzaron dicha cantidad.

  Este resultado se utiliza en el reporte R5.
  """
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

  @doc """
  Analiza la puntualidad de los repartidores que tienen al menos
  tres servicios válidos.

  Para cada repartidor elegible calcula dos medidas de retraso:

  - promedio ponderado por kilómetros;
  - promedio simple de los retrasos.

  El promedio ponderado se calcula mediante:

      suma(retraso * kilómetros) / suma(kilómetros)

  ## Parámetros

  - `validos`: lista de servicios válidos.
  - `repartidores`: lista de repartidores registrados.

  ## Retorna

  Una lista de mapas con el código, nombre, cantidad de servicios,
  retraso ponderado y promedio simple de cada repartidor elegible.

  Este resultado se utiliza para generar el reporte R6.
  """
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

   @doc """
  Calcula el costo semanal de los repartidores.

  Suma los valores netos de las liquidaciones y los kilómetros
  recorridos para obtener el costo promedio pagado por kilómetro.

  ## Parámetros

  - `liquidaciones`: lista de liquidaciones de los repartidores.

  ## Retorna

  Si existen kilómetros válidos, retorna:

      {:ok, %{total: ..., kilometros: ..., por_kilometro: ...}}

  Si no existen kilómetros, retorna:

      {:error, :sin_kilometros}

  Este resultado se utiliza para generar el reporte R7.
  """
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

  @doc """
  Identifica los repartidores que tienen al menos un servicio válido
  en todas las zonas de la empresa.

  ## Parámetros

  - `validos`: lista de servicios válidos.
  - `repartidores`: lista de repartidores registrados.
  - `zonas`: lista de zonas de la empresa.

  ## Retorna

  Una lista con los repartidores que cumplen la condición de haber
  realizado servicios válidos en cada una de las zonas.

  Este resultado se utiliza para generar el reporte R8.
  """
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

  # -----------------------------------
  # Funciones auxiliares privadas
  # -----------------------------------

  # Filtra los servicios válidos correspondientes a un repartidor.
  defp servicios_de(validos, repartidor) do
    Enum.filter(validos, fn servicio -> servicio.repartidor == repartidor.codigo end)
  end


  # Suma los kilómetros de una lista de servicios.
  defp sumar_km(servicios) do
    Enum.sum(Enum.map(servicios, fn servicio -> servicio.kilometros end))
  end
end

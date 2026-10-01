# Integrantes: [Sofia Aviles Diaz], [Santiago Barrero Lopez], [Yvette Daniela Campo Osorio]

defmodule Liquidacion do
  @tarifa_base 2500
  @km_para_bonificacion 80
  @bonificacion_diaria 15000
  @alquiler_bicicleta_dia 10000

  # Convierte un número a decimal y lo redondea a 2 decimales
  def redondear(numero), do: Float.round(numero * 1.0, 2)

  # Valor de UN servicio: kilómetros x tarifa, con el ajuste por puntualidad
  def valor_servicio(servicio) do
    valor_base = servicio.kilometros * @tarifa_base
    valor_base * factor_puntualidad(servicio.retraso)
  end

  # Cuánto se multiplica el valor según el retraso
  defp factor_puntualidad(retraso) do
    cond do
      retraso <= 0 -> 1.08
      retraso <= 10 -> 1.0
      retraso <= 30 -> 0.90
      true -> 0.75
    end
  end

  # Bonificación de un día: 15.000 si el repartidor hizo 80 km o más
  def bonificacion_dia(kilometros) do
    if kilometros >= @km_para_bonificacion do
      @bonificacion_diaria
    else
      0
    end
  end

  # Detalle por día de los servicios de UN repartidor.
  # Solo devuelve los días en los que hizo al menos un servicio.
  def detalle_dias(servicios) do
    todos_los_dias =
      for dia <- Validacion.dias() do
        del_dia = Enum.filter(servicios, fn servicio -> servicio.dia == dia end)
        kilometros = redondear(total(del_dia, :kilometros))

        %{
          dia: dia,
          cantidad: length(del_dia),
          kilometros: kilometros,
          valor_servicios: Enum.sum(Enum.map(del_dia, fn servicio -> valor_servicio(servicio) end)),
          bonificacion: bonificacion_dia(kilometros)
        }
      end

    Enum.filter(todos_los_dias, fn detalle -> detalle.cantidad > 0 end)
  end

  # Liquidación de UN repartidor (sus servicios pueden ser una lista vacía)
  def liquidar(repartidor, servicios) do
    dias = detalle_dias(servicios)

    kilometros = total(dias, :kilometros)
    valor_servicios = total(dias, :valor_servicios)
    bonificaciones = total(dias, :bonificacion)

    # Solo paga alquiler si usa bicicleta, y es por cada día trabajado
    alquiler =
      if repartidor.bicicleta do
        length(dias) * @alquiler_bicicleta_dia
      else
        0
      end

    %{
      codigo: repartidor.codigo,
      nombre: repartidor.nombre,
      kilometros: kilometros,
      valor_servicios: valor_servicios,
      bonificaciones: bonificaciones,
      alquiler: alquiler,
      neto: valor_servicios + bonificaciones - alquiler,
      dias: dias
    }
  end

  # Liquida a TODOS los repartidores (incluso a los que no tienen servicios)
  def liquidar_todos(repartidores, servicios_validos) do
    for repartidor <- repartidores do
      mis_servicios = Enum.filter(servicios_validos, fn servicio -> servicio.repartidor == repartidor.codigo end)
      liquidar(repartidor, mis_servicios)
    end
  end

  # Suma el campo indicado de una lista de mapas. Ejemplo: total(dias, :kilometros)
  defp total(lista, campo) do
    Enum.sum(Enum.map(lista, fn elemento -> Map.get(elemento, campo) end))
  end
end

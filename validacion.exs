# Integrantes: [Nombre 1], [Nombre 2], [Nombre 3]

defmodule Validacion do
  # Valores del negocio guardados como atributos del módulo
  @max_kilometros 45
  @retraso_minimo -30
  @retraso_maximo 180

  # Lista de los días de operación
  def dias, do: [1, 2, 3, 4, 5, 6]

  # Revisa las 5 reglas en orden. Con "with", si una regla devuelve
  # {:error, motivo}, se detiene ahí y devuelve ese error (el primero).
  def validar(servicio, repartidores, zonas) do
    with :ok <- validar_repartidor(servicio, repartidores),
         :ok <- validar_zona(servicio, zonas),
         :ok <- validar_dia(servicio),
         :ok <- validar_kilometros(servicio),
         :ok <- validar_retraso(servicio) do
      {:ok, servicio}
    end
  end

  # Separa la lista de servicios en dos listas: {validos, rechazados}
  def clasificar(servicios, repartidores, zonas) do
    resultados = Enum.map(servicios, fn servicio -> {servicio, validar(servicio, repartidores, zonas)} end)

    validos = for {_servicio, {:ok, valido}} <- resultados, do: valido
    rechazados = for {servicio, {:error, motivo}} <- resultados, do: {servicio, motivo}

    {validos, rechazados}
  end

  # Regla 1: el repartidor debe existir
  defp validar_repartidor(servicio, repartidores) do
    existe = Enum.any?(repartidores, fn repartidor -> repartidor.codigo == servicio.repartidor end)

    if existe do
      :ok
    else
      {:error, :repartidor_desconocido}
    end
  end

  # Regla 2: la zona debe existir
  defp validar_zona(servicio, zonas) do
    existe = Enum.any?(zonas, fn zona -> zona.id == servicio.zona end)

    if existe do
      :ok
    else
      {:error, :zona_desconocida}
    end
  end

  # Regla 3: el día debe ser un entero entre 1 y 6
  defp validar_dia(servicio) do
    dia = servicio.dia

    if is_integer(dia) and dia >= 1 and dia <= 6 do
      :ok
    else
      {:error, :dia_invalido}
    end
  end

  # Regla 4: los kilómetros deben ser un número mayor que 0 y máximo 45
  defp validar_kilometros(servicio) do
    km = servicio.kilometros

    if is_number(km) and km > 0 and km <= @max_kilometros do
      :ok
    else
      {:error, :kilometros_fuera_de_rango}
    end
  end

  # Regla 5: el retraso debe ser un número entre -30 y 180
  defp validar_retraso(servicio) do
    retraso = servicio.retraso

    if is_number(retraso) and retraso >= @retraso_minimo and retraso <= @retraso_maximo do
      :ok
    else
      {:error, :retraso_invalido}
    end
  end
end

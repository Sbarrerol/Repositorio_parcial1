# Integrantes: [Sofia Aviles Diaz], [Santiago Barrero Lopez], [Yvette Daniela Campo Osorio]

defmodule Entrada do
  # IMPURA: pide el texto al usuario y lo interpreta
  def solicitar_servicio do
    "Ingrese un servicio adicional\n(repartidor;zona;dia;kilometros;retraso)\no Enter para omitir: "
    |> Util2.ingresar(:texto)
    |> interpretar()
  end

  # Convierte el texto en :omitido, {:ok, servicio} o {:error, :formato_invalido}
  def interpretar(texto) do
    if texto == "" do
      :omitido
    else
      campos = String.split(texto, ";")
      construir_servicio(campos)
    end
  end

  # Decide qué hacer con el servicio adicional.
  # Devuelve {validos, rechazados, mensaje para el usuario}
  def incorporar(:omitido, validos, rechazados, _repartidores, _zonas) do
    {validos, rechazados, "No se ingresó ningún servicio adicional (se presionó Enter)."}
  end

  def incorporar({:error, :formato_invalido}, validos, rechazados, _repartidores, _zonas) do
    {validos, rechazados, "Servicio adicional rechazado por formato."}
  end

  def incorporar({:ok, servicio}, validos, rechazados, repartidores, zonas) do
    case Validacion.validar(servicio, repartidores, zonas) do
      {:ok, valido} ->
        {validos ++ [valido], rechazados, "Servicio adicional agregado correctamente."}

      {:error, motivo} ->
        mensaje = "Servicio adicional rechazado por la regla de validación: #{motivo}."
        {validos, rechazados ++ [{servicio, motivo}], mensaje}
    end
  end

  # Con exactamente 5 campos intenta convertir día, kilómetros y retraso
  defp construir_servicio([repartidor, zona, dia, kilometros, retraso]) do
    with {:ok, dia_entero} <- convertir_entero(String.trim(dia)),
         {:ok, km_numero} <- convertir_numero(String.trim(kilometros)),
         {:ok, retraso_numero} <- convertir_numero(String.trim(retraso)) do
      {:ok,
       %{
         repartidor: String.trim(repartidor),
         zona: String.trim(zona),
         dia: dia_entero,
         kilometros: km_numero,
         retraso: retraso_numero
       }}
    end
  end

  # Si no tiene exactamente 5 campos
  defp construir_servicio(_campos), do: {:error, :formato_invalido}

  defp convertir_entero(texto) do
    case Integer.parse(texto) do
      {numero, ""} -> {:ok, numero}
      _ -> {:error, :formato_invalido}
    end
  end

  # Acepta enteros ("5") y decimales ("22.5")
  defp convertir_numero(texto) do
    case Integer.parse(texto) do
      {numero, ""} ->
        {:ok, numero}

      _ ->
        case Float.parse(texto) do
          {numero, ""} -> {:ok, numero}
          _ -> {:error, :formato_invalido}
        end
    end
  end
end

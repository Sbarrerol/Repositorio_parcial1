defmodule Util do
  @moduledoc """
  Módulo con funciones que se reutilizan
  - autor: Julián E. Gutiérrez P.
  - fecha: Junio del 2026
  - licencia: GNU GPL v3
  """

  @doc """
  Función para mostrar un mensaje en la pantalla.

  ## Parámetro

  - mensaje: texto que se le presenta al usuario

  ## Ejemplo

  iex> Util.mostrar_mensaje("Hola Mundo")

  o puede usar

  "Hola Mundo" |> Util.mostrar_mensaje()
  """
  def mostrar_mensaje(mensaje) do
    mensaje
    |> IO.puts()
  end

  @doc """
  Función para ingresar un dato desde teclado

  ## Parámetro

  - mensaje: texto que se le presenta al usuario
  - tipo: Puede user
    :texto para ingresar una cadena
    :entero para ingresar un valor entero

  ## Ejemplo

  iex> Util.ingresar("Ingresar nombre: ", :texto)
  iex> Util.ingresar("Ingresar edad: ", :entero)

  o puede usar

  "Ingresar nombre: " |> Util.ingresar(:texto)
  "Ingresar edad: "   |> Util.ingresar(:entero)
  """
  def ingresar(mensaje, :texto) do
    mensaje
    |> IO.gets()
    |> String.trim()
  end

  def ingresar(mensaje, :real) do
    ingresar(
      mensaje,
      &String.to_float/1,
      :real
    )
  end

  def ingresar(mensaje, :entero) do
    ingresar(
      mensaje,
      &String.to_integer/1,
      :entero
    )
  end

  defp ingresar(mensaje, parser, tipo_dato) do
    try do
      mensaje
      |> ingresar(:texto)
      |> parser.()
    rescue
      ArgumentError ->
        "Error, se espera que ingrese un número #{tipo_dato}\n"
        |> mostrar_error()

        mensaje
        |> ingresar(parser, tipo_dato)
    end
  end

  def ingresar(mensaje, :entero) do
    try do
      mensaje
      |> ingresar(:texto)
      |> String.to_integer()
    rescue
      ArgumentError ->
        "Error, se espera que ingrese un número entero\n"
        |> Util.mostrar_error()

        ingresar(mensaje, :entero)
    end
  end

  def mostrar_error(mensaje) do
    IO.puts(:standard_error, mensaje)
  end

  def ingresar(mensaje, :real) do
    try do
      mensaje
      |> ingresar(:texto)
      |> String.to_float()
    rescue
      ArgumentError ->
        "Error, se espera que ingrese un número flotante\n"
        |> mostrar_error()

        mensaje
        |> ingresar(:real)
    end
  end
end

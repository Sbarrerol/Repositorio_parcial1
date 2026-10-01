# Integrantes: [Sofia Aviles Diaz], [Santiago Barrero Lopez], [Yvette Daniela Campo Osorio]

defmodule Ranking do
  # Ordena una lista de mapas (que tengan el campo :nombre).
  # Opciones (keyword list):
  #   campo:  función que devuelve el valor por el que se ordena
  #   sentido: :desc (mayor a menor, por defecto) o :asc (menor a mayor)
  #   limite: cuántos elementos devolver (por defecto, todos)
  #
  # Ejemplo:
  #   Ranking.ranking(liquidaciones, campo: fn l -> l.neto end, sentido: :desc, limite: 3)
  def ranking(elementos, opciones) do
    campo = Keyword.get(opciones, :campo, fn elemento -> elemento end)
    sentido = Keyword.get(opciones, :sentido, :desc)
    limite = Keyword.get(opciones, :limite, length(elementos))

    # Primero se ordena por nombre para que, si hay empate, quede en orden alfabético
    por_nombre = Util2.ordenar(elementos, :asc, fn elemento -> elemento.nombre end)
    ordenados = Util2.ordenar(por_nombre, sentido, campo)

    Enum.take(ordenados, limite)
  end
end

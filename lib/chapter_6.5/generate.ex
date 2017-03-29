defmodule Generate do
  @moduledoc """
  Function used to generate unique id's for neurons and other components in the NN.
  Based on the ios time clock.
  """

  @doc """
  Returns a list of ids.
  """
  def ids(0, accumulator) do
    accumulator
  end

  def ids(index, accumulator) do
    id = Generate.id()
    Generate.ids(index - 1, [id | accumulator])
  end

  def id() do
    {mega_seconds, seconds, micro_seconds} = :os.timestamp
    1/(mega_seconds * 1_000_000 + seconds + micro_seconds / 1_000_000)
  end
end

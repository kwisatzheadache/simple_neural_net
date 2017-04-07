defmodule TestGenotype do
  @moduledoc """
  constructs a generic genotype with the following command.
  Genotype.construct("ffnn.txt", "rng", "pts", [1,3])
  """
  def now do
    Genotype.construct("ffnn.txt", "rng", "pts", [1,3])
  end
end

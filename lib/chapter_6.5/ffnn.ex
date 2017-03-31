defmodule FFNN do
  def create(yourlist) do
    Genotype.construct("ffnn.txt", "rng", "pts", yourlist)
  end
end

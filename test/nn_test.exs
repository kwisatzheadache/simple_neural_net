defmodule NnTest do
  use ExUnit.Case
  doctest Nn


  test "exoself" do
    Genotype.construct("henry.txt", "rng", "pts", [3,3,3])
    Exoself.map("henry.txt")
  end
end

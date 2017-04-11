defmodule NnTest do
  use ExUnit.Case
  doctest Nn

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "genotype" do
    TestGenotype.now
  end

  test "exoself" do
    Exoself.map("ffnn.txt")
  end
end

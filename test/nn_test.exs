defmodule NnTest do
  use ExUnit.Case
  doctest Nn


  test "exoself" do
    Genotype.construct("henry.txt", "rng", "pts", [3,3,3])
    IO.inspect Genotype.read("henry.txt")
    Exoself.map("henry.txt")
    File.rm!("henry.txt")
  end
end

defmodule Clause do
  def test(input, [head | tail]) do
    IO.puts input
    IO.puts head
    IO.puts tail
  end
  def test2(input, list) do
    [head | tail] = list
    IO.puts input
    IO.puts "head is #{head}"
    IO.puts "tail is #{tail}"
  end
  def test3(input, list) do
    [head | tail] = list
  end
end

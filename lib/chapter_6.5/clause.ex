defmodule Clause do
  @moduledoc """
  This was just used to troubleshoot some error codes I was getting. It turns out, Elixir doesn't like to pattern match on an empty list. Certainly not in the context of a function call.
  """
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

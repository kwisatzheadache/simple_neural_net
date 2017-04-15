defmodule MacroTest do
  defmacro test do
    5
  end

  def print(variable) do
    IO.puts variable
    IO.puts test
  end
end

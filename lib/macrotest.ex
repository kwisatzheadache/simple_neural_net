defmodule MacroTest do
  defmacro test do
    5
  end

  # def print(variable) do
  #   IO.puts variable
  #   IO.puts test
  # end

  defmacro morphology(morph, interactor) do
    IO.puts "MacroTest loaded"
    quote do
      unquote({{:., [], [{:__aliases__, [alias: false], [:Morphology]}, morph]}, [], [interactor]})
    end
  end
end

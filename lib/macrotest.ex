defmodule MacroTest do
  defmacro test do
    5
  end

  defmacro type(name) do
    IO.puts "macro loaded"
    IO.inspect name, label: "name"
    case is_atom(name) do
      true -> IO.puts "Sensor.type loaded"
              #> quote do Sensor.create end
              #> {{:., [], [{:__aliases__, [alias: false], [:Sensor]}, :create]}, [], []}
              #  So, we should be able to substitue sensor_name for :create. Should require that sensor_name
              #  be an atom, while we're at it.
              #> quote do IO.puts "hello"
              #> {{:., [], [{:__aliases__, [alias: false], [:IO]}, :puts]}, [], ["hello"]}
              #  Perhaps I'm looking for Code.eval_quoted(ast_expression)
              ast = {{:., [], [{:__aliases__, [alias: false], [:Morphology]}, name]}, [], [:sensor]}
              # IO.puts Macro.to_string(ast)
              ast
              # Code.eval_quoted(ast)
      false -> IO.puts "sensor must be an atom"
        name
    end
  end
  # def print(variable) do
  #   IO.puts variable
  #   IO.puts test
  # end

  # defmacro morphology(morph, interactor) do
  #   IO.puts "MacroTest loaded"
  #   quote do
  #     unquote({{:., [], [{:__aliases__, [alias: false], [:Morphology]}, morph]}, [], [interactor]})
  #   end
  # end
end

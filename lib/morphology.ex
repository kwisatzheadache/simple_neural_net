defmodule Morphology do
  
  defmacro morphology(morph, interactor) do
    IO.puts "MacroTest loadee"
    quote do
      unquote({{:., [], [{:__aliases__, [alias: false], [:Morphology]}, morph]}, [], [interactor]})
    end
  end

  def xor_mimic(interactor) do
    case interactor do
      :sensor ->
        [%Sensor{id: {:sensor, Generate.id()}, name: :xor_getinput, scape: {:private, :xor_sim}, vl: 2}]
      :actuator ->
        [%Actuator{id: {:actuator, Generate.id()}, name: :xor_sendoutput, scape: {:private, :xor_sim}, vl: 1}]
    end
  end
end

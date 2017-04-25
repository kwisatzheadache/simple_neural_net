defmodule Morphology do
@moduledoc"""
Morphology creates a sensor or actuator, based upon the scape. It assigns
the scape name to the sensor/actuator struct.
"""
  def sensor_name(_) do
    IO.puts "error in MacroTest macro"
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

defmodule Morphology do
@moduledoc"""
Morphology creates a sensor or actuator, based upon the scape. It assigns
the scape name to the sensor/actuator struct.
"""
  def xor_mimic(interactor) do
    case interactor do
      :sensor ->
        [%Sensor{id: {:sensor, Generate.id()}, name: :xor_getinput, scape: {:private, :xor_sim}, vl: 2}]
      :actuator ->
        [%Actuator{id: {:actuator, Generate.id()}, name: :xor_sendoutput, scape: {:private, :xor_sim}, vl: 1}]
    end
  end

  # the rng module needs to be updated. Though, I doubt it will ever actually be used.
  def rng(interactor) do
    case interactor do
      :sensor ->
        [%Sensor{id: {:sensor, Generate.id()}, name: :rng_getinput, scape: {:private, :rng}, vl: 2}]
      :actuator ->
         [%Actuator{id: {:actuator, Generate.id()}, name: :rng_sendoutput, scape: {:private, :rng}, vl: 1}]       
    end
  end
end

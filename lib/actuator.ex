defmodule Actuator do
  @moduledoc """
  Actuators are the responsible for processing output from the NN.
  """
  defstruct id: nil, cx_id: nil, name: nil, vl: nil, fanin_ids: nil
  def create(actuator_name) do
    case actuator_name do
      "pts" ->
             %Actuator{id: {:actuator, Generate.id()}, name: "pts", vl: 1}
      :err ->
             IO.puts "system does not yet support an actuator byt the name: #{inspect actuator_name}."
    end
  end
end


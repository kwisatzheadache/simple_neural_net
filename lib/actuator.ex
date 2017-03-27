defmodule Actuator do
  @moduledoc """
  Actuators are the responsible for processing output from the NN.
  """
  defstruct id: nil, cx_id: nil, name: nil, vl: nil, fanin_ids: nil
  def create(actuator_name) do
    case actuator_name do
      pts ->
             %actuator{id: {actuator, Generate.id()}, name: pts, vl: 1}
      _ ->
             exit("system does not yet support an actuator byt the name:~p.",[actuator_name])
    end
  end
end


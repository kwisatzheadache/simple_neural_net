defmodule Sensor do
  @moduledoc """
  Sensors are responsible for creating the initial input for the NN. 
  Currently, the only supported sensor is "rng"
  """
  defstruct id: nil, cx_id: nil, name: nil, vl: nil, fanout_ids: nil

  @doc """
  Create a sensor with the specified name. Name must be chosen from the list of eligible sensors. In this case, only rng.
  """
  def create(sensor_name) do
    case sensor_name do
      "rng" ->
             %Sensor{id: {:sensor, Generate.id()}, name: "rng", vl: 2}
      _ ->
        IO.puts "System does not yes support a sensor by the name:#{inspect sensor_name} "
    end
  end
end


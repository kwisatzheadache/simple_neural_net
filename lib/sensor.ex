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

  def generate(exoself_pid, node) do
    Node.spawn(node, Sensor, :loop, [exoself_pid])
  end

  def loop(exoself_pid) do
    receive do
      {exoself_pid, {id, cx_pid, sensor_name, vl, fanout_pids}} ->
        loop(id, cx_pid, sensor_name, vl, fanout_pids)
    end
  end

  @doc """
  Once the sync message is received, it creates a sensory vector from the sensor_name and vl. 
  """
  def loop(id, cx_pid, sensor_name, vl, fanout_pids) do
    case sensor_name do
      "rng" -> sensory_vector = Sensor.rng(vl)
      _ -> IO.puts "sensor not supported"
    end
    receive do
      {cx_pid, :sync} ->
        # sensory_vector =  Sensor.sensor_name(vl)
        Send.list(fanout_pids, {self(), :forward, sensory_vector})
        loop(id, cx_pid, sensor_name, vl, fanout_pids)
      {cx_pid, :terminate} ->
        :ok
    end
  end

  @doc """
  Random number generator.
  """
  def rng(vl) do
    rng(vl, [])
  end

  def rng(vl, acc) do
    case vl do
      0 -> acc
      _ -> rng(vl - 1, [:rand.uniform() | acc])
    end
  end

end


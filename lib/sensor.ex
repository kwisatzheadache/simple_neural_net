defmodule Sensor do
  @moduledoc """
  Sensors are responsible for creating the initial input for the NN. 
  Currently, the only supported sensor is "rng"
  """
  defstruct id: nil, cx_id: nil, name: nil, scape: nil, vl: nil, fanout_ids: nil
  # import Morphology
  # import MacroTest

  @doc """
  Create a sensor with the specified name. Name must be chosen from the list of eligible sensors. In this case, only rng.
  """
  def create(sensor_name) do
  #   MacroTest.morphology(sensor_name, :sensor)
  end

  def generate(exoself_pid, node) do
    Node.spawn(node, Sensor, :loop, [exoself_pid])
  end

  def loop(exoself_pid) do
    receive do
      {exoself_pid, {id, cx_pid, sensor_name, vl, fanout_pids}} ->
        IO.puts "sensor firing"
        loop(id, cx_pid, sensor_name, vl, fanout_pids)
    end
  end

  @doc """
  Once the sync message is received, it creates a sensory vector from the sensor_name and vl. 
  """
  def loop(id, cx_pid, sensor_name, vl, fanout_pids) do
    sensory_vector = case sensor_name do
      "rng" -> Sensor.rng(vl)
      :xor_mimic -> xor_getinput(vl, nil)
      _ -> IO.puts "sensor not supported"
    end
    receive do
      {cx_pid, :sync} ->
        IO.puts "sensor received :sync signal line 42"
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

  def xor_getinput(vl, scape) do
    send scape, {self(), :sense}
    receive do
      {scape, :percept, sensory_vector} ->
        case length(sensory_vector) == vl do
          :true -> sensory_vector
          :false -> IO.puts "error in Sensor.xor_sim/2"
        end
    end
  end

end


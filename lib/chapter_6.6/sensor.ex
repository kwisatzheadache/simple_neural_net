defmodule Sensor do
  @moduledoc """
  Generates the sensor. receives message from exoself then drops into loop.
  """
  def generate(exoself_pid, node) do
    spawn(node, Sensor, :loop, [exoself_pid])
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
    receive do
      {cx_pid, :sync} ->
        sensory_vector =  Sensor.sensor_name(vl)
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

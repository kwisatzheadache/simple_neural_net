
defmodule Cortex do
  @moduledoc """
  The cortex syncronizes the NN so that each iteration is happens at the right time. It sends the initialization signals to the sensor and receives the processed output from the actuator.
  """
  defstruct id: nil, sensor_ids: [], actuator_ids: [], n_ids: []

  def create(cx_id, s_ids, a_ids, n_ids) do
    %Cortex{id: cx_id, sensor_ids: s_ids, actuator_ids: a_ids, n_ids: n_ids}
  end
end


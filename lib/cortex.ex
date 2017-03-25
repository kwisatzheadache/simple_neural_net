
defmodule Cortex do
  @moduledoc """
  The cortex syncronizes the NN so that each iteration is happens at the right time. It sends the initialization signals to the sensor and receives the processed output from the actuator.
  """
  defstruct id: nil, sensor_ids: [], actuator_ids: [], nids: []
end


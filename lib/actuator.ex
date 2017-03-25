defmodule Actuator do
  @moduledoc """
  Actuators are the responsible for processing output from the NN.
  """
  defstruct id: nil, cx_id: nil, name: nil, vl: nil, fanin_ids: nil
end


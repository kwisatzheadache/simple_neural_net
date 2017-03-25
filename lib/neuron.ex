
defmodule Neuron do
  @moduledoc """
  Neurons are the fundemenal building blocks of the NN. The activation function is for now most likely to be tanh.
  """
  defstruct id: nil, cx_id: nil, af: nil, input_idps: [], output_idps: []
end


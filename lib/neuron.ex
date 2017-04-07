
defmodule Neuron do
  @moduledoc """
  Neurons are the fundemenal building blocks of the NN. The activation function is for now most likely to be tanh.
  """
  defstruct id: nil, cx_id: nil, af: nil, input_idps: [], output_ids: []

  def create(input_idps, id, cx_id, output_ids) do
    proper_input_idps = NeuralInput.create(input_idps, [])
    %Neuron{id: id, cx_id: cx_id, af: "tanh", input_idps: proper_input_idps, output_ids: output_ids}
  end
end


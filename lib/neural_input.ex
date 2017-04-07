defmodule NeuralInput do
  @moduledoc """
  Creates the weights for the neurons. Receives the id and vector length for the neurons.
  Returns a neuron in the form of {id, weights}
  Weights are randomly generated.
  """

  def create([current_neuron | input_idps], accumulator) do
    {input_id, input_vl} = current_neuron
    weights = NeuralInput.weights(input_vl, [])
    NeuralInput.create(input_idps, [{input_id, weights} | accumulator])
  end

  def create([], accumulator) do
    :lists.reverse([{:bias, :random.uniform() - 0.5} | accumulator])
  end

  @doc """
  create weights for the neuron, given a vector length (index)
  """
  def weights(index, accumulator) do
    case index do
      0 -> accumulator
      _ -> weight = :random.uniform() - 0.5
           NeuralInput.weights(index - 1, [weight | accumulator])
    end
  end
end

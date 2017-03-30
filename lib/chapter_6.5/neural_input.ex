defmodule NeuralInput do
  @moduledoc """
  """

  def create([{input_id, input_vl} | input_idps], accumulator) do
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

defmodule Neural_Input do
  @moduledoc """
  """

  def create({{input_id, input_vl}, input_idps}, accumulator) do
    weights = Neural_Input.weights(input_vl, [])
    Neural_Input.create(input_idps, [{input_id, weights} | accumulator])
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
           Neural_Input.weights(index - 1, [weight | accumulator])
    end
  end
end

defmodule Neuro_Layers do
  @moduledoc """
  Creates the layers, according to layer_densities.
  """

  @doc """
    Neuro_Layers.create/3 creates the initial records before passing genotype infor to Neuro_Layers.create/7
    input_idps is a list of tuples - ids and vls.
    This NN uses a single sensor and actuator, so the first layor is a single sensor id, with a vl of 1.
    The same goes for the actuator.
    Finally, the call generates ids for the first layer of neurons, then drops into the recursive Neuro_Layers.create call.
    """
  #Neuro_Layers.create/4
  def create(cx_id, sensor, actuator, layer_densities) do
    input_idps = {sensor.id, sensor.vl}
    total_layers = length(layer_densities)
    [fl_neurons | next_layer_densities] = layer_densities
    n_ids = for x <- Generate.ids(fl_neurons, []), do: {:neuron, {1, x}}
    Neuro_Layers.create(cx_id, actuator.id, 1, total_layers, input_idps, n_ids, next_layer_densities, [])
 end

  #Final layer, 
  #special iteration where layer_index === total_layers
  #Neuro_Layers.create/8
  def create(cx_id, actuator_id, layer_index, total_layers, input_idps, n_ids, [next_layer_densities | layer_densities], accumulator) when layer_index === total_layers do
    output_ids = [actuator_id]
    layer_neurons = Neuro_Layers.create(cx_id, input_idps, n_ids, output_ids, [])
    :lists.reverse([layer_neurons | accumulator])
  end

  #Neuro_Layers.create/8
  def create(cx_id, actuator_id, layer_index, total_layers, input_idps, n_ids, [next_layer_densities | layer_densities], accumulator) do
    output_n_ids =  for x <- Generate.ids(next_layer_densities, []), do: {:neuron, {layer_index + 1, x}}
    layer_neurons = Neuro_Layers.create(cx_id, input_idps, n_ids, output_n_ids, [])
    next_input_idps = for x <- n_ids, do: {x, 1}
    Neuro_Layers.create(cx_id, actuator_id, layer_index + 1, total_layers, next_input_idps, output_n_ids, layer_densities, [layer_neurons | accumulator])
  end

  #Neuro_Layers.create/5
  def create(cx_id, input_idps, [id | n_ids], output_ids, accumulator) do
    neuron = Neuron.create(input_idps, id, cx_id, output_ids)
    Neuro_Layers.create(cx_id, input_idps, n_ids, output_ids, [neuron | accumulator])
  end

  def create(_cx_id, _input_idps, [], _output_ids, accumulator) do
    accumulator
  end
end

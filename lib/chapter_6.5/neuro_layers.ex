defmodule NeuroLayers do
  @moduledoc """
  Creates the layers, according to layer_densities.
  """

  @doc """
    NeuroLayers.create/3 creates the initial records before passing genotype infor to NeuroLayers.create/7
    input_idps is a list of tuples - ids and vls.
    This NN uses a single sensor and actuator, so the first layor is a single sensor id, with a vl of 1.
    The same goes for the actuator.
    Finally, the call generates ids for the first layer of neurons, then drops into the recursive NeuroLayers.create call.
    """
  def init(cx_id, sensor, actuator, layer_densities) do
    input_idps = [{sensor.id, sensor.vl}]
    total_layers = length(layer_densities)
    [fl_neurons | next_layer_densities] = layer_densities
    n_ids = for x <- Generate.ids(fl_neurons, []), do: {:neuron, x}
    NeuroLayers.create(cx_id, actuator.id, 1, total_layers, input_idps, n_ids, next_layer_densities, [])
  end

  def create(cx_id, actuator_id, layer_index, total_layers, input_idps, n_ids, densities, accumulator) do
    if layer_index == total_layers do
      output_ids = [actuator_id]
      layer_neurons = NeuroLayers.create_neurons(cx_id, input_idps, n_ids, output_ids, [])
      :lists.reverse([layer_neurons | accumulator])

    else
      [next_layer_densities | layer_densities] = densities
      output_n_ids =  for x <- Generate.ids(next_layer_densities, []), do: {:neuron, x} 
      layer_neurons = NeuroLayers.create_neurons(cx_id, input_idps, n_ids, output_n_ids, [])
      next_input_idps = for x <- output_n_ids, do: {x, 1}
      #next_input_idps = for x <- Generate.ids(next_layer_densities, []), do: {{:neuron, x}, 1}# this needs to be a list of tuples - id and vl. 
      NeuroLayers.create(cx_id, actuator_id, layer_index + 1, total_layers, next_input_idps, output_n_ids, layer_densities, [layer_neurons | accumulator])
    end
  end

  #NeuroLayers.create/5
 def create_neurons(cx_id, input_idps, n_ids, output_ids, accumulator) do
    if length(n_ids) == 0 do
      accumulator

    else
      [id | remaining_ids] = n_ids
      neuron = Neuron.create(input_idps, id, cx_id, output_ids)
      NeuroLayers.create_neurons(cx_id, input_idps, remaining_ids, output_ids, [neuron | accumulator])
    end
 end
end

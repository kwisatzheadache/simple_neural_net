defmodule Neuro_Layers do
  @moduledoc """
  Creates the layers, according to layer_densities.
  """

  @doc """
  create layers.
  """
  def create(cx_id, sensor, actuator, layer_densities) do
    #input id and vector length, gathered from the sensor
    input_idps = {sensor.id, sensor.vl}
    #total layers derived from the length of the layer_densities list
    total_layers = List.length(layer_densities)
    #first layer grabbed from the layer_densities. The remaining layers are assigned to the next_layer_densities list for the recursive Neuro_Layers.create call
    [fl_neurons | next_layer_densities] = layer_densities

    list_comp = for x <- Generate.ids(fl_neurons, []), do: {neuron, {1, x}}
    #recursive call to the create function to handle the remaining layers.
    Neuro_Layers.create(cx_id, actuator.id, 1, total_layers, input_idps, n_ids, next_layer_densities, [])
  end

  def create(cx_id, actuator_id, layer_index, total_layers, input_idps, n_ids, [next_layer_densities | layer_densities], accumulator) do
    output_n_ids =  for x <- Generate.ids(next_layer_densities, []) do: {:neuron, {layer_index + 1, x}}
    layer_neurons = Neuro_Layers.create(cx_id, input_idps, n_ids, output_n_ids, [])
    next_input_idps = for x <- n_ids, do: {x, 1}
  end
end

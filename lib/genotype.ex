
defmodule Genotype do
  @moduledoc """
  Genotypes are the underlying structure of the NN, as opposed to the phenotype, which is the expressed form.
  The Genotype module is where the basic structure of the NN is determined, as it takes the specs as input.
  """

  @doc """
  Creates a NN with the given specs. Note that the layer/density is the combined list of hidden_layer_densities and the output_vl.
  """
  def construct(file_name, sensor_name, actuator_name, hidden_layer_densities)
      S = Sensor.create(sensor_name)
      A = Actuator.create(actuator_name)
      output_vl = A.vl
      layer_densities = List.flatten([hidden_layer_densities | output_vl])
      cx_id = {cortex, generate_id()}
end

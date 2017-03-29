
defmodule Genotype do
  @moduledoc """
  Genotypes are the underlying structure of the NN, as opposed to the phenotype, which is the expressed form.
  The Genotype module is where the basic structure of the NN is determined, as it takes the specs as input.
  """

  @doc """
  Creates a NN with the given specs. Note that the layer/density is the combined list of hidden_layer_densities and the output_vl.
  """
  def construct(file_name, sensor_name, actuator_name, hidden_layer_densities) do
      #creates a sensor with the given name: note - in this chapter, we only use rng for the sensor
      s = Sensor.create(sensor_name)
      #assigns an actuator with the given name
      a = Actuator.create(actuator_name)
      #retrieve the output_vl from the actuator 
      output_vl = [a.vl]
      #concatenate the hidden_layer_densities and output_vl to get total layer densities
      layer_densities = List.flatten([hidden_layer_densities | output_vl])
      cx_id = {:cortex, Generate.id()}

      #creates the neuron layers
      neurons = NeuroLayers.init(cx_id, s, a, layer_densities)
      #separates neurons into input and output layers
      [input_layer | _] = neurons
      [output_layer | _] = Enum.reverse(neurons)
      #id lists for the first layer and last layers
      #I'm not sure if this will work. The erlang uses #neuron.id to the the id, but I'm just calling it from the map.
        # when I know more about the what the list looks like, I may have to revisit this.
      fl_n_ids = Enum.map(input_layer, fn x -> x.id end)
      ll_n_ids = Enum.map(output_layer, fn x -> x.id end)
      n_ids = Enum.map(neurons, fn x -> x.id end)
      #provide cortex and connection info to sensor
      sensor =  %{s | cx_id: cx_id, fanout_ids: fl_n_ids}
      #provide cortex and connection info actuator
      actuator = %{a | cx_id: cx_id, fanin_ids: ll_n_ids}
      #create the cortex, giving it the an id, along with info for sensor, actuator, and neurons
      cortex = Cortex.create(cx_id, [s.id], [a.id], n_ids)
      #genotype is a list of all the components. Not sure why the neurons are treated as the tail...
      genotype = List.flatten([cortex, sensor, actuator | neurons])

      # #Write the genotype to a file. Not sure if this is actually going to work...
      # {:ok, file} =  File.open(file_name, :write)
      # Enum.each(genotype, fn x -> IO.write(file, x) end)
      # File.close(file)
  end
end


defmodule Genotype do
  @moduledoc """
  Genotypes are the underlying structure of the NN, as opposed to the phenotype, which is the expressed form.
  The Genotype module is where the basic structure of the NN is determined, as it takes the specs as input.
  Use Genotype.read("file_name") to read a genotype.
  Use Genotype.construct to create a NN.
  """

  @doc """
  Creates a NN with the given specs. Note that the layer/density is the combined list of hidden_layer_densities and the output_vl.
  construc(file_name, sensor_name, actuator_name, hidden_layer_densities)
  file_name should be a string, ie. "my_nn.txt"
  sensor_name is currently limited to "rng" since this nn, only uses a random number generator as its sensor.
  similarly, actuator_name is limited to "pts"
  hidden_layer_densities must be a list... [1,2,3] or something like that.


  example: Genotype.construct("ffnn.txt", "rng", "pts", [1,3])

  The command `TestGenotype.now` runs the above construct command.
  """
  def construct(file_name, sensor_name, actuator_name, hidden_layer_densities) do
      s = Sensor.create(sensor_name)
      a = Actuator.create(actuator_name)
      output_vl = [a.vl]
      #concatenate the hidden_layer_densities and output_vl to get total layer densities
      layer_densities = List.flatten([hidden_layer_densities | output_vl])
      cx_id = {:cortex, Generate.id()}

      #creates the neuron layers
      neurons = NeuroLayers.init(cx_id, s, a, layer_densities)
      flat_neurons = List.flatten(neurons)
      [input_layer | _] = neurons
      [output_layer | _] = Enum.reverse(neurons)
      #id lists for the first layer and last layers
      fl_n_ids = Enum.map(input_layer, fn x -> x.id end)
      ll_n_ids = Enum.map(output_layer, fn x -> x.id end)
      IO.inspect neurons
      n_ids = Enum.map(flat_neurons, fn x -> x.id end)
      IO.inspect n_ids
      #provide cortex and connection info to sensor
      sensor =  %{s | cx_id: cx_id, fanout_ids: fl_n_ids}
      #provide cortex and connection info actuator
      actuator = %{a | cx_id: cx_id, fanin_ids: ll_n_ids}
      #create the cortex, giving it the an id, along with info for sensor, actuator, and neurons
      cortex = Cortex.create(cx_id, [s.id], [a.id], n_ids)
      #genotype is a list of all the components. Not sure why the neurons are treated as the tail...
      genotype = List.flatten([cortex, sensor, actuator | neurons])

       #Write the genotype to a file. Not sure if this is actually going to work...
      File.write! file_name, :erlang.term_to_binary(genotype)
      # {:ok, file} =  File.open(file_name, [:write])
      # Enum.each(genotype, fn x -> IO.write(file, x) end)
      # IO.write(file, genotype)
      # File.close(file)
  end

  @doc """
  Since the genotypes are written using the :erlang.term_to_binary call, read(genotype) is used to read previously generated genotypes.
  ex: read("ffnn.txt")
  """
  def read(genotype) do
    File.read!(genotype) |> :erlang.binary_to_term
  end

  def save_genotype(file_name, genotype) do
    t_id = :ets.new(file_name, [:public, :set, {:keypos, 2}])
    Enum.each(genotype, fn x -> :ets.insert(t_id, x) end)
    :ets.tab2file(t_id, file_name)
  end

  def save_to_file(genotype, file_name) do
    :ets.tab2file(genotype, file_name)
  end
end

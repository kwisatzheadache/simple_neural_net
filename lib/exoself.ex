defmodule Exoself do
  @moduledoc """
  """

  @doc """
  """
  def map() do
    map(ffnn)
  end

  def map(file_name) do
    {:ok, genotype} = Genotype.read(file_name)
    spawn(Exoself, :map, [file_name, genotype])
  end

  def map(file_name, genotype) do
    ids_npids = :ets.new(:ids_npids, [:set, :prive])
    [cx | cerebral_units] = Genotype.read(file_name)
    sensor_ids = cx.sensor_ids
    actuator_ids = cx.actuator_ids
    n_ids = cx.n_ids
    spawn_cerebral_units(ids_npids, :cortex, [cx.id])
    spawn_cerebral_units(ids_npids, :sensor, sensor_ids)
    spawn_cerebral_units(ids_npids, :actuator, actuator_ids)
    spawn_cerebral_units(ids_npids, :neuron, n_ids)
    link_cerebral_units(cerebral_units, ids_npids)
    link_cortex(cx, ids_npids)
    cx_pid = :ets.lookup_element(ids_npids, cx.id, 2)
    receive do
      {cd_pid, :backup, neuron_ids_nweights} ->
        u_genotype = Update.genotype(ids_npids, genotype, neuron_ids_nweights)
        {:ok, file} = File.open(file_name, :write)
        Enum.each(genotype, fn x -> IO.write(file, "#{x}") end)
        File.close(file_name)
        IO.puts "Finished updating to file: #{file_name}"
    end
  end

  def spawn_cerebral_units(ids_npids, cerebral_unit_type, [id | ids]) do
    pid = case cerebral_unit_type do
            :cortex -> Cortex.generate(self(), node())
            :neuron -> Neuron.generate(self(), node())
            :actuator -> Actuator.generate(self(), node())
            :sensor -> Sensor.generate(self(), node())
          end
    :ets.insert(ids_npids, {id, pid})
    :ets.insert(ids_npids, {pid, id})
    spawn_cerebral_units(ids_npids, cerebral_unit_type, ids)
  end

  def link_cerebral_units(records, ids_npids) do
    [r | tail_records] = records
    case r.id do
      {:sensor, id} -> link_sensor(records, ids_npids)
      {:actuator, id} -> link_actuator(records, ids_npids)
      {:neuron, id} -> link_neuron(records, ids_npids)
      _ -> :ok
    end
  end
end

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
    Spawn.cerebral_units(ids_npids, cx, sensor_ids)
    Spawn.cerebral_units(ids_npids, cx, actuator_ids)
    Spawn.cerebral_units(ids_npids, cx, n_ids)
    Link.cerebral_units(cerebral_units, ids_npids)
    Link.cortex(cx, ids_npids)
    cx_pid = :ets.lookup_element(ids_npids, cx.id, 2)
    
  end
end

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

  def spawn_cerebral_units(ids_npids, cerebral_unit_type, ids) do
    if length(ids) == 0 do
      :true
    else
      [id | tail_ids] =  ids
      pid = case cerebral_unit_type do
              :cortex -> Cortex.generate(self(), node())
              :neuron -> Neuron.generate(self(), node())
              :actuator -> Actuator.generate(self(), node())
              :sensor -> Sensor.generate(self(), node())
              _ -> IO.puts "error in spawn_cerebral_units function call"
            end
      :ets.insert(ids_npids, {id, pid})
      :ets.insert(ids_npids, {pid, id})
      spawn_cerebral_units(ids_npids, cerebral_unit_type, tail_ids)
    end
  end

  def link_cerebral_units(records, ids_npids) do
    if length(records) == 0 do
      :ok
    else
      [r | tail_records] = records
      case r.id do
        {:sensor, id} -> link_sensor(r, tail_records, ids_npids)
        {:actuator, id} -> link_actuator(r, tail_records, ids_npids)
        {:neuron, id} -> link_neuron(r, tail_records, ids_npids)
        _ -> :ok
      end
    end
  end

  # I've chosen to send [r | tail_records] = records as separate arguments. This may
  # cause trouble down the line, but I think I did it right.
  def link_sensor(r, tail_records, ids_npids) do
    s_id = r.id
    s_pid = :ets.lookup_element(ids_npids, s_id, 2)
    cx_pid = :ets.lookup_element(ids_npids, r.cx_id, 2)
    s_name = r.name
    fanout_ids = r.fanout_ids
    fanout_pids = Enum.map(fanout_ids, fn x -> :ets.lookup_element(ids_npids, x, 2) end)
    send s_pid, {self(), {s_id, cx_pid, s_name, r.vl, fanout_pids}}
    link_cerebral_units(tail_records, ids_npids)
  end

  def link_actuator(r, tail_records, ids_npids) do
    a_id = r.id
    a_pid = :ets.lookup_element(ids_npids, a_id, 2)
    cx_pid = :ets.lookup_element(ids_npids, r.cx_id, 2)
    a_name = r.name
    fanin_ids = r.fanin_ids
    fanin_pids = Enum.map(fanin_ids, fn x -> :ets.lookup_element(ids_npids, x, 2) end)
    send a_pid, {self(), {a_id, cx_pid, a_name, fanin_pids}}
    link_cerebral_units(tail_records, ids_npids)
  end

  def link_neuron(r, tail_records, ids_npids) do
    n_id = r.id
    n_pid = :ets.lookup_element(ids_npids, n_id, 2)
    cx_pid = :ets.lookup_element(ids_npids, r.cx_id, 2)
    af_name = r.af
    input_idps = r.input_idps
    output_ids = r.output_ids
    input_pidps = convert_ids_to_pids(ids_npids, input_idps, [])
    output_pids = Enum.map(output_ids, fn x -> :ets.lookup_element(ids_npids, x, 2) end)
    send n_pid, {self(), {n_id, cx_pid, af_name, input_pidps, output_pids}}
    link_cerebral_units(tail_records, ids_npids)
  end

  def link_cortex(cx, ids_npids) do
    cx_id = cx.id
    cx_pid = :ets.lookup_element(ids_npids, cx_id, 2)
    s_ids = cx.sensor_ids
    a_ids = cx.actuator_ids
    n_ids = cx.n_ids
    s_pids = Enum.map(s_ids, fn x -> :ets.lookup_element(ids_npids, x, 2) end)
    a_pids = Enum.map(a_ids, fn x -> :ets.lookup_element(ids_npids, x, 2) end)
    n_pids = Enum.map(n_ids, fn x -> :ets.lookup_element(ids_npids, x, 2) end)   
    send cx_pid, {self(), {cx_id, s_pids, a_pids, n_pids}, 1000}
  end

  def update_genotype(ids_npids, genotype, neuron_ids_nweights) do
    if length(neuron_ids_nweights) == 0 do
      genotype
    else
      [{n_id, pidps} | weights_ps] = neuron_ids_nweights
      n = :lists.keyfind(n_id, 2, genotype)
      IO.puts "pidps: #{pidps}"
      updated_input_idps = convert_pidps_to_idps(ids_npids, pidps, [])
      u_n = %{n | input_idps: updated_input_idps}
      u_genotype = :lists.keyreplace(n_id, 2, genotype, u_n)
    end
  end

  def convert_ids_to_pids(ids_npids, input_idps, acc) do
    case length(input_idps) do
      0 -> IO.puts "error in Exoself.convert_id_to_pids module"
      1 -> [{:bias, bias}] = input_idps
           :lists.reverse([bias | acc])
      _ -> [{id, weights} | fanin_idps] = input_idps
           convert_ids_to_pids(ids_npids, fanin_idps, [{:ets.lookup_element(ids_npids, id, 2), weights} | acc])
    end
  end

end

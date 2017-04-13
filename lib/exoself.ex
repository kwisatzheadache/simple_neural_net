defmodule Exoself do
  @moduledoc """
  The Exoself module is responsible for creating the NN from the information contained in the genotype.
  It reads the genotype from the given file and creates accordingly.
  """

  @doc """
  This generates a genotype and feeds it, along with the source file to the map function. It may seem
  counter-intuitive to send the same information twice, but this is so that when the map/2 is called
  later with a source genotype and an alternate, the same process will be enacted.
  """
    def map(file_name) do
    genotype = Genotype.read(file_name)
    spawn(Exoself, :map, [file_name, genotype])
  end


  @doc """
  This is where the magic happens. A table is created with the erlang call :ets.new/2 so that all
  processes can push and pul information to the same source. It is called ids_npids, it is a random seed.

  Take the case of a :neuron. The Exoself.spawn_cerebral_units takes the id of the neuron being spawned,
  and links it with the PID received Neuron.generate(self(), node()) call. This tuple, {n_id, PID}
  is then pushed to the table. The table itself winds up looking something like this.

  iex> :ets.i(ids_npids)
  <1   > {<0.195.0>,{cortex,0.8863365168735315}}
  <2   > {<0.216.0>,{actuator,0.40465764440758645}}
  <3   > {<0.225.0>,{neuron,0.9972234354362616}}
  <4   > {{sensor,0.28483516273019394},<0.203.0>}
  <5   > {{neuron,0.6892255213216225},<0.224.0>}
  <6   > {<0.224.0>,{neuron,0.6892255213216225}}
  <7   > {<0.203.0>,{sensor,0.28483516273019394}}
  <8   > {{cortex,0.8863365168735315},<0.195.0>}
  <9   > {{neuron,0.9972234354362616},<0.225.0>}
  <10  > {{actuator,0.40465764440758645},<0.216.0>}
  
  Finally, the link_cerebral_units and link_cortex calls tie together all the PIDS and then the nn
  is running.
  """
  def map(file_name, genotype) do
    ids_npids = :ets.new(:ids_npids, [:set, :private])
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
    IO.inspect cx_pid, label: "cx_pid"
    IO.inspect :ets.i(ids_npids)
    receive do
      {cx_pid, :backup, neuron_ids_nweights} ->
        u_genotype = update_genotype(ids_npids, genotype, neuron_ids_nweights)
        {:ok, file} = File.open(file_name, :write)
        Enum.each(u_genotype, fn x -> IO.write(file, "#{x}") end)
        File.close(file_name)
        IO.puts "Finished updating to file: #{file_name}"
    end
  end

  def spawn_cerebral_units(ids_npids, cerebral_unit_type, ids) do
    if length(ids) == 0 do
      IO.puts "spawn_cerebral_units complete"
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

  @doc """
  Calls corresponding link_* function. 
  """
  def link_cerebral_units(records, ids_npids) do
    if length(records) == 0 do
      IO.puts "link_cerebral_units complete"
      :ok
    else
      [r | tail_records] = records
      case r.id do
        {:sensor, _} -> link_sensor(r, tail_records, ids_npids)
        {:actuator, _} -> link_actuator(r, tail_records, ids_npids)
        {:neuron, _} -> link_neuron(r, tail_records, ids_npids)
        _ -> :ok
      end
    end
  end

  @doc """
  Explanation carries over to link_actuator and link_neuron as well.
  Gathers pid info from :ets table and creates pid lists for fan_in and fan_out neurons.

  Important step: sends all of that info to the sensor (s_pid).

  Continues recursively to handle a list of sensors.
  """
  def link_sensor(r, tail_records, ids_npids) do
    s_id = r.id
    s_pid = :ets.lookup_element(ids_npids, s_id, 2)
    cx_pid = :ets.lookup_element(ids_npids, r.cx_id, 2)
    s_name = r.name
    fanout_ids = r.fanout_ids
    fanout_pids = Enum.map(fanout_ids, fn x -> :ets.lookup_element(ids_npids, x, 2) end)
    send s_pid, {self(), {s_id, cx_pid, s_name, r.vl, fanout_pids}}
    IO.puts "link_sensor"
    link_cerebral_units(tail_records, ids_npids)
  end

  @doc"""
  See link_sensor for explanation
  """
  def link_actuator(r, tail_records, ids_npids) do
    a_id = r.id
    a_pid = :ets.lookup_element(ids_npids, a_id, 2)
    cx_pid = :ets.lookup_element(ids_npids, r.cx_id, 2)
    a_name = r.name
    fanin_ids = r.fanin_ids
    fanin_pids = Enum.map(fanin_ids, fn x -> :ets.lookup_element(ids_npids, x, 2) end)
    send a_pid, {self(), {a_id, cx_pid, a_name, fanin_pids}}
    IO.puts "link_actutator"
    link_cerebral_units(tail_records, ids_npids)
  end

  @doc"""
  See link_sensor for explanation

  Creates input_idps with all of the PID information and vector lengths.
  """
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
    IO.puts "link_neurons"
    link_cerebral_units(tail_records, ids_npids)
  end

  @doc"""
  Sends cortex the master list - cortex, sensors, neurons, actuators - all of the PIDS, as well as
  a counter placeholder which signals termination of the nn cycles.
  """
  def link_cortex(cx, ids_npids) do
    cx_id = cx.id
    cx_pid = :ets.lookup_element(ids_npids, cx_id, 2)
    s_ids = cx.sensor_ids
    a_ids = cx.actuator_ids
    n_ids = cx.n_ids
    s_pids = Enum.map(s_ids, fn x -> :ets.lookup_element(ids_npids, x, 2) end)
    a_pids = Enum.map(a_ids, fn x -> :ets.lookup_element(ids_npids, x, 2) end)
    n_pids = Enum.map(n_ids, fn x -> :ets.lookup_element(ids_npids, x, 2) end)   
    IO.puts "cortex linking and sends"
    send cx_pid, {self(), {cx_id, s_pids, a_pids, n_pids}, 1000}
  end

  @doc"""
  This enumerates over the list of neurons and corresponding weights, updating the input_idps for
  each neuron in the genotype. It returns a the updated_genotype, with all the new weights (and later
  on, the new connections, perhaps).
  Recursively maps over a list of neurons, updating them one by one, using the update_input_idps and is_id
  calls.
  """
  def update_genotype(ids_npids, genotype, neuron_ids_nweights) do
    if length(neuron_ids_nweights) == 0 do
      genotype
    else
      [{n_id, pidps} | weights_ps] = neuron_ids_nweights
      n = :lists.keyfind(n_id, 2, genotype)
      IO.puts "pidps: #{pidps}"
      updated_input_idps = convert_pidps_to_idps(ids_npids, pidps, [])
      u_genotype = update_input_idps(genotype, n_id, updated_input_idps)
      #u_n = %{n | input_idps: updated_input_idps}
      #u_genotype = :lists.keyreplace(n_id, 2, genotype, u_n)
      update_genotype(ids_npids, u_genotype, weights_ps)
    end
  end

  @doc"""
  With is_id, maps over the genotype. Each case in the list is fed to the is_id - if it matches
  the neuron_id, it's input_idps is updated.
  """
  def update_input_idps(genotype, neuron_id, new_input_idps) do
    Enum.map(genotype, fn x -> is_id(x, neuron_id, new_input_idps) end)
  end

  def is_id(x, neuron_id, new_input_idps) do
    if x.id == neuron_id do
      %{x | input_idps: new_input_idps}
    else
      x
    end
  end

  @doc"""
  Go between id and pid. Useful for input_idps which is just {neuron_id, vl},  rather than
  {neuron_id, PID, vl}
  """
  def convert_ids_to_pids(ids_npids, input_idps, acc) do
    case length(input_idps) do
      0 -> IO.puts "error in Exoself.convert_id_to_pids module"
      1 -> [{:bias, bias}] = input_idps
           :lists.reverse([bias | acc])
      _ -> [{id, weights} | fanin_idps] = input_idps
           convert_ids_to_pids(ids_npids, fanin_idps, [{:ets.lookup_element(ids_npids, id, 2), weights} | acc])
    end
  end

  def convert_pidps_to_idps(ids_npids, pidps, acc) do
    case length(acc)  do
      0 -> IO.puts "error in Exoself.convert_pisps_to_idps module"
      1 -> [bias] = pidps
           :lists.reverse([{:bias, bias} | acc])
      _ -> [{pid, weights} | input_pidps] = pidps
           convert_pidps_to_idps(ids_npids, input_pidps, [{:ets.lookup_element(ids_npids, pid, 2), weights} | acc])
    end
  end

end

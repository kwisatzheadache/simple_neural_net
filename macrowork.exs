genotype = Genotype.read("henry.txt")
table = :ets.new(:ids_npids, [:set, :private])
[cx | cerebral_units] = genotype
s_ids = cx.sensor_ids
a_ids = cx.actuator_ids
n_ids = cx.n_ids
Exoself.spawn_cerebral_units(table, :cortex, [cx.id])
Exoself.spawn_cerebral_units(table, :sensor, s_ids)
Exoself.spawn_cerebral_units(table, :actuator, a_ids)
Exoself.spawn_cerebral_units(table, :neuron, n_ids)
Exoself.link_cerebral_units(cerebral_units, table)
Exoself.link_cortex(cx, table)
cx_pid = :ets.lookup_element(table, cx.id, 2)
IO.puts "genotype loaded"
IO.inspect s_ids
IO.inspect a_ids
IO.inspect n_ids
IO.inspect cx_pid
:ets.i(table)

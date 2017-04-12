# Nn
This is a basic walkthrough of Gene Sher's "Handbook on Neuroevolution
Through Erlang," translated to Elixir. I'm new to this kind of thing, 
so expect plenty of errors along the way, as well as improperly structured
code, etc, while I learn. 


# Testing

To run a quick test of the app sofar, clone the repo, then do the following:

`mix test`

Be aware, it won't look like much is happening... yet.

Alternatively, to create your own feed forward neural net, do this:

`iex -S mix`
``` elixir
ffnn = FFNN.create(your_list)
```

Where `your_list` is the Layer Density list of your choosing. `[1,2,3]` or
`[2,4,3]`, for example. 

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `nn` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:nn, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/nn](https://hexdocs.pm/nn).

# Progress and Questions

I've finished chapter 6.5 - the genotype constructor. 

Update 4/10 - Chapter 6.6 is done. The mix test now constructs a genotype and a 
corresponding phenotype. It runs quickly, doesn't look like it's doing much
because it doesn't have a training algorithm yet. I also need to do docs.

4/12 Question concerning performance.

`iex -S mix`

```elixir
Genotype.construct("simplestnn.txt", "rng", "pts", [1])
Exoself.map("simplestnn.txt")
```

That will generate a genotype for a nn with [1,1] structure, two neurons in total and one sensor/actuator.
The code runs fine, but then my terminal runs so slowly I can't really manipulate it at all. This is quite 
unexpected - there should be only six or so processes in total, so I'm not sure what the issue might be.
``` elixir
Genotype.construct("simplestnn.txt", "rng", "pts", [1])
ids_npids = :ets.new(:ids_npids, [:set, :private])
[cx | cerebral_units] = Genotype.read("simplestnn.txt")
sensor_ids = cx.sensor_ids
actuator_ids = cx.actuator_ids
n_ids = cx.n_ids
Exoself.spawn_cerebral_units(ids_npids, :cortex, [cx.id])
Exoself.spawn_cerebral_units(ids_npids, :sensor, sensor_ids)
Exoself.spawn_cerebral_units(ids_npids, :actuator, actuator_ids)
Exoself.spawn_cerebral_units(ids_npids, :neuron, n_ids)
```

No problems up until this poing.

```elixir
Exoself.link_cerebral_units(cerebral_units, ids_npids)
Exoself.link_cortex(cx, ids_npids)
```

See the PID's print the the REPL, but then it slows so much I can't do any tests with the code. Is my computer
too slow?
#

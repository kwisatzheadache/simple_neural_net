# Nn
This is a basic walkthrough of Gene Sher's "Handbook on Neuroevolution
Through Erlang," translated to Elixir. I'm new to this kind of thing, 
so expect plenty of errors along the way, as well as improperly structured
code, etc, while I learn. 


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

# Progress

Right now, I'm troubleshooting the genotype generator from Chapter 6 Part 5. 
I seem to be having troubles with the NeuroLayers module. I'm not entirely
sure what's wrong (I have no idea). I think something isn't being looped
right in the recursion. It is looping indefinitely.

Update: The problem is in the creation of n_ids in the NeuroLayers/8 step.
I'm fairly certain. I'm too tired to figure it out now, but I think
that it's not creating the list of n_ids properly.

Update 2: Specifically, in the NeuralInput.create function, the neuron seems
to have a list of three tuples, rather than one. They are identical.
That's the problem. Somewhere when input_idps is generated, it is generating
a single tuple three times, rather than three new ones.

So, it's probably in one of the ''''for x <- [list], do:'''' statements.

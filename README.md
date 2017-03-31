# Nn
This is a basic walkthrough of Gene Sher's "Handbook on Neuroevolution
Through Erlang," translated to Elixir. I'm new to this kind of thing, 
so expect plenty of errors along the way, as well as improperly structured
code, etc, while I learn. 


# Testing

To run a quick test of the app sofar, clone the repo, then do the following:

`mix test`

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

# Progress

Right now, I'm finishing up the genotype creator from Chapter 6.5. It works
properly, I just need to fix the write stage to output to a nice neat file.

See above for code to run Genotype constructor. 

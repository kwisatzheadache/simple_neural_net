# Nn
This is a basic walkthrough of Gene Sher's "Handbook on Neuroevolution
Through Erlang," translated to Elixir. I'm new to this kind of thing, 
so expect plenty of errors along the way, as well as improperly structured
code, etc, while I learn. 


# Testing

To run a quick test of the app sofar, clone the repo, then do the following:

`mix test`

This generates the genotype of a NN with 1 sensor, 1 actuator, and [1,3,3,3]
neurons, named "henry.txt"

The genotype is subsequently used to generate the neural net itself, complete
with (in this case) 10 neurons. See there PID's and all their connectivity 
printed out to the console. 

The training module will be soon to follow.

Alternatively, to create your own feed forward neural net, do this:

`iex -S mix`
``` elixir
FFNN.create(your_list)
Exoself.map("ffnn.txt")
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

Update 4/10 - Genotype constructor completed.

4/12 Question concerning performance.
Solved the question. See previous commits.

4/15 Phenotype generator up and running.
I had hoped to have the training module by this point, but it seems Mr. Sher
had about five things he wanted to do before finishing the training module,
so I've just cleaned up the functional Phenotype generator and put up a clean
testfile. Run the `mix test` to see where we're at.

4/18 Learning how to rewrite EVERYTHING with macros, so that it actually 
trains. Might be a few days before there's another major breakthrough. 
`mix test` working again.

4/25 Working with macros. Call `Sensor.create(:xor_mimic)` and begin troubleshooting.

4/30 Wondering if I can actually figure out how to make it train. The code
is not very clean and I don't understand where to begin. 
#

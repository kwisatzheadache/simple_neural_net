# defmodule FindingKeys do
#   def by_id(genotype, neuron_id, new_input_idps) do
#     Enum.map(genotype, fn x -> is_id(x, neuron_id, new_input_idps) end)
#   end

#   def is_id(x, neuron_id, new_input_idps) do
#     if x.id == neuron_id do
#       %{x | input_idps: new_input_idps}
#     else
#       x
#     end
#   end
# end



# #FindingKeys.by_id(genotype, neuron_id, "this works")


defmodule Neuron do
  @moduledoc """
  Neurons are the fundemenal building blocks of the NN. The activation function is for now most likely to be tanh.
  """
  defstruct id: nil, cx_id: nil, af: nil, input_idps: [], output_ids: []

  def create(input_idps, id, cx_id, output_ids) do
    proper_input_idps = NeuralInput.create(input_idps, [])
    %Neuron{id: id, cx_id: cx_id, af: "tanh", input_idps: proper_input_idps, output_ids: output_ids}
  end

  def generate(exoself_pid, node) do
    Node.spawn(node, Neuron, :loop, [exoself_pid])
  end

  def loop(exoself_pid) do
    receive do
      {exoself_pid, {id, cx_pid, af, input_pidps, output_pids}} ->
        IO.puts "neuron loop firing."
        loop(id, cx_pid, af, [{input_pidps}, {input_pidps}], output_pids, 0)
    end
  end

  def loop(id, cx_pid, af, input_pidps_info, output_pids, acc) do
    all_input_pidps = [1]
    m_input_pidps = [1,1,1]
    IO.inspect input_pidps_info, label: input_pidps_info
    # [{all_input_pidps, m_input_pidps}] = input_pidps_info
    IO.puts "neuron loop part two firing"
     # case length(all_input_pidps) do
     #   0 ->
     #     IO.puts "l == 0"
     #    output = Neuron.tanh(acc)
     #    Send.list(output_pids, {self(), :forward, [output]})
     #    IO.puts "neuron acc = 0"
     #    loop(id, cx_pid, af, {m_input_pidps, m_input_pidps}, output_pids, 0)
     #   1 ->
     #     IO.puts " l == 1"
     #    [bias] = all_input_pidps
     #    output = Neuron.tanh(acc + bias)
     #    Send.list(output_pids, {self(), :forward, [output]})
     #    IO.puts "neuron acc = 1"
     #    loop(id, cx_pid, af, {m_input_pidps, m_input_pidps}, output_pids, 0)
     #   _ ->
     #     IO.puts "l == _"
     #    [{input_pid, weights} | input_pidps] = all_input_pidps
     #    IO.puts "neuron acc = _"
     #    receive do
     #      {input_pid, :forward, input} ->
     #       result = dot(input, weights, 0)
     #        loop(id, cx_pid, af, {input_pidps, m_input_pidps}, output_pids, result + acc)
     #      {cx_pid, :get_backup} ->
     #        send cx_pid, {self(), id, m_input_pidps}
     #      {cx_pid, :terminate} ->
     #        :ok
     #    end
     # end
  end

  def dot(inputs, weights, acc) do
    case length(inputs) do
      0 ->
        acc
      _ ->
        [i | input] = inputs
        [w | weight] = weights
        dot(input, weight, i * w + acc)
    end
  end

  def tanh(val) do
    :math.tanh(val)
  end
 end



defmodule Neuron do
  @moduledoc """
  Neurons are the fundemenal building blocks of the NN. The activation function is for now most likely to be tanh.
  """
  defstruct id: nil, cx_id: nil, af: nil, input_idps: [], output_ids: []

  defmacro delta_multiplier do
    :math.pi() * 2
  end

  defmacro sat_limit do
    :math.pi() * 2
  end

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
        IO.puts "neuron firing."
        loop(id, cx_pid, af, [input_pidps, input_pidps], output_pids, 0)
    end
  end

  def loop(id, cx_pid, af, all_input_pidps, output_pids, acc) do
    #all_input_pidps = [1]
    #m_input_pidps = [1,1,1]
    IO.inspect(all_input_pidps)
    [a_input_pidps, m_input_pidps] = all_input_pidps
     case length(a_input_pidps) do
       0 ->
        output = Neuron.tanh(acc)
        Send.list(output_pids, {self(), :forward, [output]})
        loop(id, cx_pid, af, [m_input_pidps, m_input_pidps], output_pids, 0)
       1 ->
        [bias] = a_input_pidps
        output = Neuron.tanh(acc + bias)
        Send.list(output_pids, {self(), :forward, [output]})
        loop(id, cx_pid, af, [m_input_pidps, m_input_pidps], output_pids, 0)
       _ ->
         # IO.puts "neuron acc = _"
         [{input_pid, weights} | input_pidps] = a_input_pidps
        receive do
          {input_pid, :forward, input} ->
           result = dot(input, weights, 0)
            loop(id, cx_pid, af, [input_pidps, m_input_pidps], output_pids, result + acc)
          {cx_pid, :get_backup} ->
            send cx_pid, {self(), id, m_input_pidps}
          {cx_pid, :terminate} ->
            :ok
        end
     end
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


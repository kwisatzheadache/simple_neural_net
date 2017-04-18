
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

  def generate(exoself_pid, node, :loop) do
    Node.spawn(node, Neuron, :loop, [exoself_pid])
  end

  def generate(exoself_pid, node) do
    Node.spawn(node, Neuron, :prep, [exoself_pid])
  end

  def prep(exoself_pid) do
    {v1, v2, v3} = :random.seed()
    receive do
      {exoself_pid, {id, cx_pid, tanh, input_pidps, output_pids}} ->
        loop(id, exoself_pid, cx_pid, tanh, {input_pidps, input_pidps}, output_pids, 0)
    end
  end
#written to page 230, top of page
  def loop(id, exoself_pid, cx_pid, tanh, a_and_m_input_pidps, output_pids, acc) do
    {a_input_pidps, m_input_pidps} = a_and_m_input_pidps
    [{input_pid, weights} | input_pidps] = a_input_pidps
    case length(a_input_pidps) do
      1 ->
        bias = a_input_pidps
        output = tanh(acc + bias)
        Send.list(output_pids, {self(), :forward, [output]})
        loop(id, exoself_pid, cx_pid, tanh, {m_input_pidps, m_input_pidps}, output_pids, 0)
      0 ->
        output = tanh(acc)
        Send.list(output_pids, {self(), :forward, [output]})
        loop(id, exoself_pid, cx_pid, tanh, {m_input_pidps, m_input_pidps}, output_pids, 0)
      _ ->
        receive do
          {input_pid, :forward, input} ->
            result = dot(input, weights, 0)
            loop(id, exoself_pid, cx_pid, tanh, {input_pidps, m_input_pidps}, output_pids, result + acc)
          {exoself_pid, :weight_backup} ->
            Process.put(:weights, m_input_pidps)
            loop(id, exoself_pid, cx_pid, tanh, {[{input_pid, weights} | input_pidps], m_input_pidps}, output_pids, acc)
          {exoself_pid, :weight_restore} ->
            r_input_pidps = Process.get(:weights)
            loop(id, exoself_pid, cx_pid, tanh, {r_input_pidps, r_input_pidps}, output_pids, acc)
          {exoself_pid, :weight_perturb} ->
            p_input_pidps = perturb_ipidps(m_input_pidps)
            loop(id, exoself_pid, cx_pid, tanh, {p_input_pidps, p_input_pidps}, output_pids, acc)
          {exoself_pid, :get_backup} ->
            send exoself_pid, {self(), id, m_input_pidps}
            loop(id, exoself_pid, cx_pid, tanh, {[{input_pid, weights} | input_pidps], m_input_pidps}, output_pids, acc)
          {exoself_pid, :terminate} ->
            :ok
        end
    end
  end

  # def dot(input, weight, acc) do
  #   case length(input) do
  #     0 -> acc
  #     _ -> 
  #       [i | inputs] = input
  #       [w | weights] = weight
  #       dot(inputs, weights, i * w + acc)
  #   end
  # end

  def perturb_ipidps(input_pidps) do
    tot_weights = Enum.sum(for {input_pid, weights} <- input_pidps, do: length(weights))
    mp = 1 / :math.sqrt(tot_weights)
    perturb_ipidps(mp, input_pidps, [])
  end

  def perturb_ipidps(mp, inputs, acc) do
    case length(inputs) do
      0 ->
        :lists.reverse(acc)
      1 ->
        [bias] = inputs
        u_bias = case :random.uniform < mp do
                   :true -> sat((:random.uniform - 0.5) * Neuron.delta_multiplier + bias, 0.0 - Neuron.sat_limit, Neuron.sat_limit)
                   :false -> bias
                 end
        :lists.reverse([u_bias | acc])
      _ ->
        [{input_pid, weights} | input_pidps] = inputs
        u_weights = perturb_weights(mp, input_pidps, [])
        perturb_ipidps(mp, input_pidps, [{input_pid, u_weights} | acc])
    end
  end

  def perturb_weights(mp, weight, acc) do
    case length(weight) do
      0 ->
        :lists.reverse(acc)
      _ ->
        [w | weights] = weight
        u_w = case :random.uniform < mp do
                :true -> sat((:random.uniform - 0.5) * Neuron.delta_multiplier + w, 0.0 - Neuron.sat_limit, Neuron.sat_limit)
                :false -> w
              end
        perturb_weights(mp, weights, [u_w | acc])
    end
  end

  def sat(val, min, max) do
    cond do
      val < min -> min
      val > max -> max
      true -> val
    end
  end

  def loop(exoself_pid) do
    receive do
      {exoself_pid, {id, cx_pid, tanh, input_pidps, output_pids}} ->
        IO.puts "neuron firing."
        loop(id, cx_pid, tanh, [input_pidps, input_pidps], output_pids, 0)
    end
  end

  def loop(id, cx_pid, tanh, all_input_pidps, output_pids, acc) do
    #all_input_pidps = [1]
    #m_input_pidps = [1,1,1]
    IO.inspect(all_input_pidps)
    [a_input_pidps, m_input_pidps] = all_input_pidps
     case length(a_input_pidps) do
       0 ->
        output = Neuron.tanh(acc)
        Send.list(output_pids, {self(), :forward, [output]})
        loop(id, cx_pid, tanh, [m_input_pidps, m_input_pidps], output_pids, 0)
       1 ->
        [bias] = a_input_pidps
        output = Neuron.tanh(acc + bias)
        Send.list(output_pids, {self(), :forward, [output]})
        loop(id, cx_pid, tanh, [m_input_pidps, m_input_pidps], output_pids, 0)
       _ ->
         # IO.puts "neuron acc = _"
         [{input_pid, weights} | input_pidps] = a_input_pidps
        receive do
          {input_pid, :forward, input} ->
           result = dot(input, weights, 0)
            loop(id, cx_pid, tanh, [input_pidps, m_input_pidps], output_pids, result + acc)
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


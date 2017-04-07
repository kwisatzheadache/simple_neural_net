defmodule ExoNeuron do
  @moduledoc """
  """

  @doc"""
  """
  def generate(exoself_pid, node) do
    Node.spawn(node, ExoNeuron, :loop, [exoself_pid])
  end

  def loop(exoself_pid) do
    receive do
      {exoself_pid, {id, cx_pid, af, input_pidps, output_pids}} ->
        loop(id, cx_pid, af, {input_pidps, input_pidps}, output_pids, 0)
    end
  end

  def loop(id, cx_pid, af, input_pidps_info, output_pids, acc) do
    {all_input_pidps, m_input_pidps} = input_pidps_info
    case length(all_input_pidps) do
      0 ->
        output = ExoNeuron.af(acc)
        Send.list(output_pids, {self(), :forward, [output]})
        loop(id, cx_pid, af, {m_input_pidps, m_input_pidps}, output_pids, 0)
      1 ->
        bias = all_input_pidps
        output = ExoNeuron.af(acc + bias)
        Send.list(output_pids, {self(), :forward, [output]})
        loop(id, cx_pid, af, {m_input_pidps, m_input_pidps}, output_pids, 0)
      _ ->
        [{input_pid, weights} | input_pidps] = all_input_pidps
        receive do
          {input_pid, :forward, input} ->
            result = dot(input, weights, 0)
            loop(id, cx_pid, af, {input_pidps, m_input_pidps}, output_pids, result + acc)
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

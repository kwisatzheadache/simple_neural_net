defmodule Actuator do
  @moduledoc """
  Actuators are the responsible for processing output from the NN.
  Currently supported actuators include "pts"... that's it. 
  """
  defstruct id: nil, cx_id: nil, name: nil, scape: nil, vl: nil, fanin_ids: nil
  defmacro easy(name) do
    quote do
      {{:., [], [{:__aliases__, [alias: false], [:Morphology]}, unquote(name)]}, [], [:actuator]}
    end
  end

  def create(actuator_name) do
    ast = easy(actuator_name)
    Code.eval_quoted(ast)
  end

  def generate(exoself_pid, node) do
    Node.spawn(node, Actuator, :loop, [exoself_pid])
  end

  def loop(exoself_pid) do
    receive do
      {exoself_pid, {id, cx_pid, actuator_name, fanin_pids}} ->
        loop(id, cx_pid, actuator_name, {fanin_pids, fanin_pids}, [])
    end
  end

  def loop(id, cx_pid, a_name, all_fanins, acc) do
    {pids, m_fanin_pids} = all_fanins
    case length(pids) do
      0 -> Actuator.pts(:lists.reverse(acc))
            send cx_pid, {self(), :sync}
            loop(id, cx_pid, a_name, {m_fanin_pids, m_fanin_pids}, [])

      _ ->  [from_pid | fanin_pids] = pids
            receive do
              {from_pid, :forward, input} ->
                    loop(id, cx_pid, a_name, {fanin_pids, m_fanin_pids}, input ++ acc)
              {cx_pid, :terminate} ->
                    :ok
            end


    end
  end

  def xor_send_output(output, scape) do
    send scape, {self(), :action, output}
    receive do
      {scape, fitness, halt_flag} ->
        {fitness, halt_flag}
    end
  end

  def pts(result) do
    # IO.puts "Actuator.pts(result): #{result}"
    IO.inspect result, label: "pts(result)"
  end

  def xor_mimic(result) do
    IO.inspect result, label: "xor_mimic result"
  end
end


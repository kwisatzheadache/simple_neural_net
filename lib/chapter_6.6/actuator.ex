defmodule Actuator do
  @moduledoc """
  """

  @doc """
  """
  def generate(exoself_pid, node) do
    spawn(node, Actuator, :loop, [exoself_pid])
  end

  def loop(exoself_pid) do
    receive do
      {exoself_pid, {id, cx_pid, actuator_name, fanin_pids}} ->
        loop(id, cx_pid, actuator_name, {fanin_pids, fanin_pids}, [])
    end
  end

  def loop(id, cx_pid, a_name, all_fanins, acc) do
    {pids, m_fanin_pids} = all_fanins
    case pids do

      _ ->  [from_pid | fanin_pids] = pids
            receive do
              {from_pid, :forward, input} ->
                    loop(id, cx_pid, a_name, {fanin_pids, m_fanin_pids}, input ++ acc)
              {cx_pid, :terminate} ->
                    :ok
            end

      [] -> Actuator.a_name(:lists.reverse(acc))
            send cx_pid, {self(), :sync}
            loop(id, cx_pid, a_name, {m_fanin_pids, m_fanin_pids}, [])

    end
  end

  def pts(result) do
    IO.puts"Actuator.pts(result): #{result}"
  end
end

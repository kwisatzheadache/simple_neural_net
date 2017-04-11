defmodule Actuator do
  @moduledoc """
  Actuators are the responsible for processing output from the NN.
  Currently supported actuators include "pts"... that's it. 
  """
  defstruct id: nil, cx_id: nil, name: nil, vl: nil, fanin_ids: nil

  def create(actuator_name) do
    case actuator_name do
      "pts" ->
             %Actuator{id: {:actuator, Generate.id()}, name: "pts", vl: 1}
      :err ->
             IO.puts "system does not yet support an actuator byt the name: #{inspect actuator_name}."
    end
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

  def pts(result) do
    # IO.puts "Actuator.pts(result): #{result}"
    IO.inspect result, label: pts(result)
  end
end


defmodule Cortex.ExoSelf do
  @moduledoc """
  The exoself is responsible for sending :sync and :terminate messages to teh neurons, sensors, and activators.
  It receives a message - {exoself_pid, {id, s_pids, a_pids, n_pids}, totat_steps}
  And then begins the loop to train the neuron.
  At each iteration,  it stores actuator data in the m_a_pids and pulls it in the next iteration.

  """

  @doc """
  Creates the exoself_pid.

  Cortex.ExoSelf.create(exoself_pid, node)
  """
  def generate(exoself_pid, node) do
    spawn(node, Cortex.Exoself, :loop, [exoself_pid])
  end

  # loop/1
  def loop(exoself_pid) do
    receive do
      {exoself_pid, {id, s_pids, a_pids, n_pids}, total_steps} ->
        Enum.each(s_pids, fn x -> send x, {self(), :sync} end)
        loop(id, exoself_pid, s_pids, {a_pids, a_pids}, n_pids, total_steps)
    end
  end

  # loop/6
  def loop(id, exoself_pid, s_pids, a_and_m_pids, n_pids, steps) do

    if steps == 0 do
      {a_pids, m_a_pids} = a_and_m_pids
                    IO.puts "Cortex is backing up and terminating #{id}"
                    neuron_ids_n_weights = get_backup(n_pids, [])
                    send exoself_pid, {self(), :backup, neuron_ids_n_weights}
                    Send.lists([s_pids, m_a_pids, n_pids], {self(), :terminate})
                    # Send.list(s_pids, {self(), :terminate})
                    # Send.list(m_a_pids, {self(), :terminate})
                    # Send.list(n_pids, {self(), :terminate})
                   # Enum.each(s_pids, fn x -> send x, {self(), :terminate} end)
                    # Enum.each(m_a_pids, fn x -> send x, {self(), :terminate} end)
                    # Enum.each(n_pids, fn x -> send x, {self(), :terminate} end)

    else
      {a_pids, m_a_pids} = a_and_m_pids
      length_a_pids = length(a_pids)
      case length_a_pids do
          _ ->
                    [a_pid | a_pids_leftover] = m_a_pids
                    receive do
                            {a_pid, :sync} ->
                                            loop(id, exoself_pid, s_pids, {a_pids_leftover, m_a_pids}, n_pids, steps)
                            :terminate ->
                                              IO.puts"Cortex is terminating #{id}"
                                              Send.lists([s_pids, m_a_pids, n_pids], {self(), :terminate})
                                              # Send.list(s_pids, {self(), :terminate})
                                              # Send.list(m_a_pids, {self(), :terminate})
                                              # Send.list(n_pids, {self(), :terminate})
                    end
          0 ->
                    Send.list(s_pids, {self(), :sync}) 
                    loop(id, exoself_pid, s_pids, {m_a_pids, m_a_pids}, n_pids, steps - 1)

      end
    end
  end

  def get_backup(n_pids, acc) do
    case n_pids do
      [] ->
            acc
      _  ->
            [n_pid | remaining_n_pids] = n_pids
            send n_pid, {self(), :get_backup}
            receive do
              {n_pid, n_id, weight_tuples} ->
                get_backup(remaining_n_pids, [{n_id, weight_tuples} | acc])

            end
     end
   end
end


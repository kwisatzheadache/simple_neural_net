
defmodule Cortex do
  @moduledoc """
  The cortex syncronizes the NN so that each iteration is happens at the right time. It sends the initialization signals to the sensor and receives the processed output from the actuator.
  """
  defstruct id: nil, sensor_ids: [], actuator_ids: [], n_ids: [],
    exoself_pid: nil, s_pids: nil, n_pids: nil, a_pids: nil, cycle_acc: 0, fitness_acc: 0,
    endflag: 0, status: nil

  def create(cx_id, s_ids, a_ids, n_ids) do
    %Cortex{id: cx_id, sensor_ids: s_ids, actuator_ids: a_ids, n_ids: n_ids}
  end

  def generate(exoself_pid, node, :loop) do
    Node.spawn(node, Cortex, :loop, [exoself_pid])
  end

  def generate(exoself_pid, node) do
    Node.spawn(node, Cortex, :prep, [exoself_pid])
  end
  # loop/1
  def loop(exoself_pid) do
    receive do
      {exoself_pid, {id, s_pids, a_pids, n_pids}, total_steps} ->
         # This is the step which is slowing us down so much... 
         Enum.each(s_pids, fn x -> send x, {self(), :sync} end)
         loop(id, exoself_pid, s_pids, {a_pids, a_pids}, n_pids, 0) #total_steps)
    end
  end

  # loop/6
  def loop(id, exoself_pid, s_pids, a_and_m_pids, n_pids, steps) do

    if steps == 0 do
      IO.puts "works up til here. cortex line 29"
      {a_pids, m_a_pids} = a_and_m_pids
                    IO.puts "Cortex is backing up and terminating "
                    neuron_ids_n_weights = get_backup(n_pids, [])
                    send exoself_pid, {self(), :backup, neuron_ids_n_weights}
                    Send.lists([s_pids, m_a_pids, n_pids], {self(), :terminate})
                    Send.list(s_pids, {self(), :terminate})
                    Send.list(m_a_pids, {self(), :terminate})
                    Send.list(n_pids, {self(), :terminate})
                    Enum.each(s_pids, fn x -> send x, {self(), :terminate} end)
                    Enum.each(m_a_pids, fn x -> send x, {self(), :terminate} end)
                    Enum.each(n_pids, fn x -> send x, {self(), :terminate} end)

    else
      {a_pids, m_a_pids} = a_and_m_pids
      length_a_pids = length(a_pids)
      case length_a_pids do
          0 ->
                    Send.list(s_pids, {self(), :sync}) 
                    loop(id, exoself_pid, s_pids, {m_a_pids, m_a_pids}, n_pids, steps - 1)
                    IO.puts "counting #{steps}"

          _ ->
                    [a_pid | a_pids_leftover] = m_a_pids
          IO.puts "cortex firing line 52"
                    receive do
                            {a_pid, :sync} ->
                                            loop(id, exoself_pid, s_pids, {a_pids_leftover, m_a_pids}, n_pids, steps - 1)
                            :terminate ->
                                              IO.puts"Cortex is terminating #{id}"
                                              Send.lists([s_pids, m_a_pids, n_pids], {self(), :terminate})
                                              # Send.list(s_pids, {self(), :terminate})
                                              # Send.list(m_a_pids, {self(), :terminate})
                                              # Send.list(n_pids, {self(), :terminate})
                    end
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

  def prep(exoself_pid) do
    {v1, v2, v3} = :random.seed
    receive do
      {exoself_pid, p_id, id, s_pids, n_pids, a_pids} ->
        Process.put(:start_time, now())
        Send.list(s_pids, {self(), :sync})
        loop(id, exoself_pid, s_pids, {a_pids, a_pids}, n_pids, 1, 0, 0, :active)
    end
  end

  def loop(id, exoself_pid, s_pids, a_and_m_pids, n_pids, cycle_acc, fitness_acc, h_f_acc, :active) do
  end

end


defmodule Scape do
  def generate(exoself_pid, node) do
    Node.spawn(node, Scape, :prep, [exoself_pid])
  end

  def prep(exoself_pid) do
    receive do
      {exoself_pid, name} ->
        case name do
          :xor_sim -> xor_sim(exoself_pid)
          _ -> IO.puts "scape not supported"
        end
    end
  end

  def xor_sim(exoself_pid) do
    xor = [{[-1, -1], [-1]},
           {[ 1, -1], [ 1]},
           {[-1,  1], [ 1]},
           {[ 1,  1], [-1]}]
    xor_sim(exoself_pid, {xor, xor}, 0)
  end

  def xor_sim(exoself_pid, xors, err_acc) do
    {[{input, correct_output} | xor], mxor} = xors
    receive do
      {from, :sense} ->
        send from, {self(), :percept, input}
        xor_sim(exoself_pid, xors, err_acc)
      {from, :action, output} ->
        error = list_compare(output, correct_output, 0)
        case xor do
          [] ->
            m_s_e = :math.sqrt(err_acc + error)
            fitness = 1 / (m_s_e + 0.00001)
            send from, {self(), fitness, 1}
            xor_sim(exoself_pid, {mxor, mxor}, 0)
          _ ->
            send from, {self(), 0, 0}
            xor_sim(exoself_pid, {xor, mxor}, err_acc + error)
        end
    end
  end

  def list_compare(list1, list2, err_acc) do
    case list1 do
      [] -> :math.sqrt(err_acc)
      _  -> [x | tail1] = list1
            [y | tail2] = list2
            list_compare(tail1, tail2, err_acc + :math.pow(x - y, 2))
    end
  end
end

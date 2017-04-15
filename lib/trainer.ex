defmodule Trainer do
  @moduledoc"""
  """

  defmacro max_Attempts do
    5
  end

  defmacro eval_Limit do
    :inf
  end

  defmacro fitness_Target do
    :inf
  end
  @doc"""
  """
  def go(morphology, hld) do
    go(morphology, hld, Trainer.max_Attempts, Trainer.eval_Limit, Trainer.fitness_Target)
  end

  def go(morphology, hld, max_attempts, eval_limit, fitness_target) do
    p_id = spawn(:trainer, :loop, [morphology, hld, fitness_target, {1, max_attempts},
                                  {0, eval_limit}, {0, :best}, :experimental])
    register(:trainer, p_id)
  end

  def loop(morphology, _hld, ft, {attempt_acc, ma}, {eval_acc, el}, {best_fitness, best_g},
    _exp_g, c_acc, t_acc) when (attempt_acc >= ma) or (eval_acc >= el) or (best_fitness >= ft) do
      Genotype.print(best_g)
      IO.puts "morphology: #{morphology}, Best Fitness #{best_fitness}, eval_acc #{eval_acc}"
  end

  def loop(morphology, hld, ft, {attempt_acc, ma}, {eval_acc, eval_limit}, {best_fitness, best_g},
   exp_g, c_acc, t_acc) do
    Genotype.construct(exp_g, morphology, hld)
    agent_pid = Exoself.map(exp_g)
    receive do
      {agent_pid, fitness, evals, cycles, time} ->
        u_eval_acc = eval_acc + evals
        u_c_acc = c_acc + cycles
        u_t_acc = t_acc + time
        case fitness > best_fitness do
          :true -> :file.rename(exp_g, best_g)
          Trainer.loop(morphology, hld, ft, {1, ma}, {u_eval_acc, eval_limit}, {best_fitness, best_g},
            exp_g, u_c_acc, u_t_acc)
          :false -> Trainer.loop(morphology, hld, ft, {attempt_acc + 1, ma}, {u_eval_acc, eval_limit},
            best_fitness, best_g}, exp_g, u_c_acc, u_t_acc)
        end
      :terminate ->
        IO.puts "trainer terminated"
        Genotype.print(best_g)
        IO.puts  "morphology: #{morphology}, Best Fitness #{best_fitness}, eval_acc #{eval_acc}"
    end
  end
end

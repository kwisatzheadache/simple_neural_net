defmodule Send do
  @moduledoc"""
  Module for automating send/2 functionality
  """

  @doc """
  Send a list of pids a message.

  Send.list([pids], {self(), :terminate})
  """
  def list(list, msg) do
    Enum.each(list, fn x -> send x, msg end)
  end

  def lists(lists, msg) do
    Enum.each(lists, fn x -> Send.list(x, msg) end)
  end
end

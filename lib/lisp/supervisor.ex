defmodule Lisp.Supervisor do
  use Supervisor

  def start_link() do
    result = {:ok, sup } = Supervisor.start_link(__MODULE__, []) 
    start_workers(sup)
    result
  end

  def start_workers(sup) do
    start_worker(sup, Lisp.EnvStash, :global.whereis_name(Lisp.EnvStash))
    start_worker(sup, Lisp.Parser, :global.whereis_name(Lisp.Parser))
    start_worker(sup, Lisp.Printer, :global.whereis_name(Lisp.Printer))
  end

  defp start_worker(sup, name, :undefined) do
    {:ok, _pid} = Supervisor.start_child(sup, worker(name, []))
  end
  defp start_worker(_sup, _name, _global) do
    :ok
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end

end

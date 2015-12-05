defmodule Lisp do
  use Application

  def start(), do: start(0, 0)
  def start(_type, _args) do
    Lisp.Supervisor.start_link
    Lisp.Repl.run
  end
end

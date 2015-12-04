defmodule Lisp do

  def start do
    Lisp.EnvStash.start_link
    Lisp.Repl.run
  end
end

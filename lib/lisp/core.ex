defmodule Lisp.Core do
  def readline(prompt) do
    IO.write(:stdio, prompt)
    IO.read(:stdio, :line)
      |> String.strip(?\n)
  end
end

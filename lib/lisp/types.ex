defmodule Lisp.Types do
  def integer?(input) do
    Regex.match?(~r/^-?[0-9]+$/, input)
  end

  def list(ast), do: {:list, ast}
end

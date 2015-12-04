defmodule Lisp.Printer do
  @moduledoc """
  Prints out an AST item.

  ## Examples

      iex> Lisp.Printer.print_str({:symbol, "+"})
      "+"

      iex> Lisp.Printer.print_str(123)
      "123"

      iex> Lisp.Printer.print_str("abc")
      "abc"

      iex> Lisp.Printer.print_str("(+ 1 2)")
      "(+ 1 2)"

  """

  def print_str(nil), do: "nil"
  def print_str({:symbol, value}), do: value
  def print_str(value) when is_integer(value), do: Integer.to_string(value)
  def print_str(value) when is_bitstring(value), do: value
  def print_str({:list, list}) do
    "(#{print_list(list)})"
  end

  defp print_list(list) do
    list
    |> Enum.map(fn(item) -> print_str(item) end)
    |> Enum.join(" ")
  end
end

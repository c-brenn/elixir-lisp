defmodule Lisp.Parser do
  @moduledoc """
  Parses a line of input.

  ## Examples

    Literal Values
      iex> Lisp.Parser.parse_str("123")
      123

    Symbols
      iex> Lisp.Parser.parse_str("+")
      {:symbol, "+"}

    Lists
      iex> Lisp.Parser.parse_str("(1 2)")
      {:list, [1, 2]}

    Function application - represented as a list
      iex> Lisp.Parser.parse_str("(+ 1 2)")
      {:list, [{:symbol, "+"}, 1, 2]}
  """
  use GenServer
  import Lisp.Types

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__ )
  end

  def parse(input) do
    GenServer.call(__MODULE__, {:parse, input})
  end

  def handle_call({:parse, input}, _, _) do
    {:reply, parse_str(input), []}
  end

  def parse_str(input) do
    case tokenize(input) do
      [] -> nil
      tokens -> tokens
        |> parse_form
        |> elem(0)
    end
  end

  defp tokenize(input) do
    regex = ~r/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
    Regex.scan(regex, input, capture: :all_but_first)
      |> List.flatten
      |> List.delete_at(-1)
      |> Enum.filter(fn token -> not String.starts_with?(token, ";") end)
  end

  defp parse_form([first | rest]) do
    case first do
      "(" -> parse_list rest
      _   ->
        token = parse_atom first
        {token, rest}
    end
  end

  defp parse_list(tokens) do
    {ast, rest} = parse_sequence(tokens, [], "(", ")")
    {list(ast), rest}
  end

  defp parse_sequence([], _acc, _s_sep, e_sep) do
    throw {:error, "expected #{e_sep}, got EOF."}
  end
  defp parse_sequence([head|tail] = tokens, acc, s_sep, e_sep) do
    cond do
      String.starts_with?(head, e_sep) ->
        {Enum.reverse(acc), tail}
      true ->
        {token, rest} = parse_form(tokens)
        parse_sequence(rest, [token | acc], s_sep, e_sep)
    end
  end

  defp parse_atom(token) do
    cond do
      integer?(token) ->
        Integer.parse(token)
          |> elem(0)
      true-> {:symbol, token}
    end
  end
end

defmodule Lisp.Reader do
  import Lisp.Types

  @doc ~S"""
  Parses a line of input. 

  ## Examples

    iex> Lisp.Reader.read_str("123")
    123

    iex> Lisp.Reader.read_str("+")
    {:symbol, "+"}

    iex> Lisp.Reader.read_str("(1 2)")
    {:list, [1, 2]}

    iex> Lisp.Reader.read_str("(+ 1 2)")
    {:list, [{:symbol, "+"}, 1, 2]}
  """

  def read_str(input) do
    case tokenize(input) do
      [] -> nil
      tokens -> tokens
        |> read_form
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

  defp read_form([first | rest]) do
    case first do
      "(" -> read_list rest
      _   -> 
        token = read_atom first
        {token, rest}
    end
  end

  defp read_list(tokens) do
    {ast, rest} = read_sequence(tokens, [], "(", ")")
    {list(ast), rest}
  end

  defp read_sequence([], _acc, _s_sep, e_sep) do
    throw {:error, "expected #{e_sep}, got EOF."}
  end
  defp read_sequence([head|tail] = tokens, acc, s_sep, e_sep) do
    cond do
      String.starts_with?(head, e_sep) ->
        {Enum.reverse(acc), tail}
      true ->
        {token, rest} = read_form(tokens)
        read_sequence(rest, [token | acc], s_sep, e_sep)
    end
  end

  defp read_atom(token) do
    cond do
      integer?(token) ->
        Integer.parse(token)
          |> elem(0)
      true-> {:symbol, token}
    end
  end
end

defmodule Lisp.Eval do
  @doc ~S"""
  Evaluates a parsed expression

  ## Examples

    iex>Lisp.Eval.evaluate(1)
    1

    iex>Lisp.Eval.evaluate({:list, [{:symbol, "+"}, 2, 2]})
    4
  """

  @env %{
    "+" => &+/2,
    "*" => &*/2,
    "-" => &-/2,
    "/" => &div/2
  }

  def evaluate(ast, env \\ @env), do: _eval(ast, env)

  defp _eval({:list, ast}, env), do: eval_list(ast, env)
  defp _eval(ast, env), do: eval_ast(ast, env)

  defp eval_ast({:symbol, sym}, env) do
    case Map.fetch(env, sym) do
      {:ok, value} -> value
      :error -> throw({:error, "Symbol '#{sym}' not found"})
    end
  end

  defp eval_ast({:list, ast}, env) do
    {:list, Enum.map(ast, fn(x) -> evaluate(x, env) end)}
  end

  defp eval_ast(ast, _env), do: ast

  defp eval_list(list, env) do
    {:list, [functor|args]} = eval_ast({:list, list}, env)
    apply(functor, args)
  end

end

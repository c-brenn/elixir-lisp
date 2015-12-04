defmodule Lisp.Eval do
  @moduledoc ~S"""
  Evaluates a parsed expression

  ## Examples

    Literal values
      iex>Lisp.Eval.evaluate(1)
      1

    Function application
      iex>Lisp.Eval.evaluate({:list, [{:symbol, "+"}, 2, 2]})
      4

    Definitions
      iex>Lisp.Eval.evaluate({:list, [{:symbol, "def!"}, {:symbol, "x"}, 10]})
      10

    Let clauses
      iex>Lisp.Eval.evaluate({:list,
      ...>[{:symbol, "let*"}, {:list, [{:symbol, "c"}, 2]},
      ...>{:symbol, "c"}]})
      2
  """

  alias Lisp.Env

  def evaluate(ast, env \\ Env.new_root_env), do: _eval(ast, env)

  defp _eval({:list, ast}, env), do: eval_list(ast, env)
  defp _eval(ast, env), do: eval_ast(ast, env)

  defp eval_ast({:symbol, sym}, env) do
    case Env.get(env, sym) do
      {:ok, value} -> value
      {error, message} -> throw({:error, "#{error} - #{message}"})
    end
  end

  defp eval_ast({:list, ast}, env) when is_list(ast) do
    {:list, Enum.map(ast, fn(x) -> _eval(x, env) end)}
  end

  defp eval_ast(ast, _env), do: ast

  defp eval_let_bindings([], env), do: env
  defp eval_let_bindings([{:symbol, key}, expr | _tail], env) do
    evaluated_expr = _eval(expr, env)
    Env.set(env, key, evaluated_expr)
    evaluated_expr
  end
  defp eval_let_bindings(_bindings, _env) do
    throw({:error, "Unbalanced let* bindings"})
  end

  defp eval_list([{:symbol, "def!"}, {:symbol, key}, value], env) do
    evaluated = _eval(value, env)
    Env.set(env, key, evaluated)
    evaluated
  end

  defp eval_list([{:symbol, "let*"}, {:list, bindings}, expression], env) do
    let_env = Env.new(env)
    eval_let_bindings(bindings, let_env)
    _eval(expression, let_env)
  end

  defp eval_list(list, env) do
    {:list, [functor|args]} = eval_ast({:list, list}, env)
    apply(functor, args)
  end
end

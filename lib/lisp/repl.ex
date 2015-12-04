defmodule Lisp.Repl do

  @repl_env %{
    "+" => &+/2,
    "*" => &*/2,
    "-" => &-/2,
    "/" => &div/2
  }

  def run(), do: repl_loop

  defp repl_loop do
    Lisp.Core.readline("elisp> ")
      |> read_eval_print
      |> IO.puts
    repl_loop
  end

  defp read_eval_print(:eof), do: exit(:normal)
  defp read_eval_print(input) do
    read(input)
      |> eval(@repl_env)
      |> print
  end

  defp read(input) do
    Lisp.Reader.read_str(input)
  end

  defp eval({:list, ast}, env), do: eval_list(ast, env)
  defp eval(ast, env), do: eval_ast(ast, env)

  defp eval_ast({:symbol, sym}, env) do
    case Map.fetch(env, sym) do
      {:ok, value} -> value
      :error -> throw({:error, "Symbol '#{sym}' not found"})
    end
  end

  defp eval_ast({:list, ast}, env) do
    {:list, Enum.map(ast, fn(x) -> eval(x, env) end)}
  end

  defp eval_ast(ast, _env), do: ast

  defp eval_list(list, env) do
    {:list, [functor|args]} = eval_ast({:list, list}, env)
    apply(functor, args)
  end

  defp print(input) do
    Lisp.Printer.print_str(input)
  end
end

defmodule Lisp.Repl do
  def run() do
    env = Lisp.EnvStash.root_env
    repl_loop(env)
  end

  defp repl_loop(env) do
    Lisp.Core.readline("elisp> ")
      |> read_eval_print(env)
      |> IO.puts
    repl_loop(env)
  end

  defp read_eval_print("exit",_), do: exit(:normal)
  defp read_eval_print(input, env) do
    read(input)
      |> eval(env)
      |> print
  catch
    {:error, message} -> IO.puts("Error: #{message}")
  end

  defp read(input) do
    Lisp.Parser.parse_str(input)
  end

  defp eval(input, env) do
    Lisp.Eval.evaluate(input, env)
  end

  defp print(input) do
    Lisp.Printer.print_str(input)
  end
end

defmodule Lisp.Repl do
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
      |> eval
      |> print
  end

  defp read(input) do
    Lisp.Parser.parse_str(input)
  end

  defp eval(input) do
    Lisp.Eval.evaluate(input)
  end

  defp print(input) do
    Lisp.Printer.print_str(input)
  end
end

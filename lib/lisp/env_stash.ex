defmodule Lisp.EnvStash do
  use GenServer
  alias Lisp.Env

  def start_link(root_env \\ Env.new_root_env) do
    GenServer.start_link(__MODULE__, root_env, name: {:global, __MODULE__})
  end

  def root_env() do
    GenServer.call({:global, __MODULE__}, :root_env)
  end

  def handle_call(:root_env, _from, root_env) do
    {:reply, root_env, root_env}
  end
end

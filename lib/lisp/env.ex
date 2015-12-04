defmodule Lisp.Env do

  @doc ~S"""
  Stores the environments in a linked list of agents
  """

  @root_env %{
    "+" => &+/2,
    "*" => &*/2,
    "-" => &-/2,
    "/" => &div/2
  }

  def new(outer_env \\ nil, keys \\ [], values \\ [])
  def new(outer_env, _keys, _values) do
    {:ok, pid} = Agent.start_link(fn ->
        %{outer_env: outer_env, env: %{}}
    end)
    pid
  end

  def new_root_env() do
    {:ok, pid} = Agent.start_link(fn ->
      %{outer_env: nil, env: @root_env }
    end)
    pid
  end
  
  def set(pid, key, value) do
    Agent.update(pid, fn env ->
      %{env | env: Map.put(env.env, key, value)}
    end)
  end

  def get(pid, key) do
    case find(pid, key) do
      nil -> {:not_found, "Could not find key #{inspect key}"}
      env -> _get(env, key)
    end
  end

  defp find(pid, key) do
    Agent.get(pid, fn state ->
      case Map.has_key?(state.env, key) do
        true -> pid
        false -> state.outer_env && find(state.outer_env, key)
      end
    end)
  end

  defp _get(pid, key) do
    Agent.get(pid, fn state ->
      {:ok, _value} = Map.fetch(state.env, key)
    end)
  end
end

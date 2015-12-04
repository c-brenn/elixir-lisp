defmodule Lisp.EnvTest do
  use ExUnit.Case, async: true
  doctest Lisp.Env
  alias Lisp.Env

  setup do
    env = Env.new()
    {:ok, env: env}
  end

  test "a new env has no bindings", %{env: env} do
    assert Env.get(env, "nope") == {:not_found, "Could not find key \"nope\""}
  end

  test "set sets values", %{env: env} do
    Env.set(env, "key", "value")
    
    assert Env.get(env, "key") == {:ok, "value"}
  end

  test "get looks in outer scopes", %{env: env} do
    Env.set(env, "outer_key", "value")
    inner_env = Env.new(env)

    assert Env.get(inner_env, "outer_key") == {:ok, "value"}
  end

  test "a new root scope has all the correct bindings" do
    root_env = Env.new_root_env

    assert Env.get(root_env, "+") == {:ok, &+/2}
    assert Env.get(root_env, "*") == {:ok, &*/2}
    assert Env.get(root_env, "-") == {:ok, &-/2}
    assert Env.get(root_env, "/") == {:ok, &div/2}
  end

end

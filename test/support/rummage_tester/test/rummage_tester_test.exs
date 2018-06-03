defmodule RummageTesterTest do
  use ExUnit.Case
  doctest RummageTester

  test "greets the world" do
    assert RummageTester.hello() == :world
  end
end

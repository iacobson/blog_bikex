defmodule BikexTest do
  use ExUnit.Case
  doctest Bikex

  test "greets the world" do
    assert Bikex.hello() == :world
  end
end

defmodule TgptTest do
  use ExUnit.Case
  doctest Tgpt

  test "greets the world" do
    assert Tgpt.hello() == :world
  end
end

defmodule CardRuleTest do
  @moduledoc false
  use ExUnit.Case
  alias Raw.Game.CardRule

  test "full house with 1 three without attachment" do
    assert CardRule.check([3, 3, 3], {:full_house, 1, 0}) == {:ok, {:full_house, 1, 0}}
  end

  test "full house with 1 three 1 left" do
    assert CardRule.check([3, 3, 3, 1], {:full_house, 1, 1}) == {:ok, {:full_house, 1, 1}}
  end

  test "full house with 2 three 1 left" do
    assert CardRule.check([3, 3, 3, 4, 4, 4, 2, 1], {:full_house, 2, 1}) ==
             {:ok, {:full_house, 2, 1}}
  end

  test "full house with 2 three with same attachment" do
    assert CardRule.check([3, 3, 3, 4, 4, 4, 2, 2], {:full_house, 2, 1}) ==
             {:ok, {:full_house, 2, 1}}
  end

  test "full house with 2 three without attachment" do
    assert CardRule.check([3, 3, 3, 4, 4, 4], {:full_house, 2, 0}) ==
             {:ok, {:full_house, 2, 0}}
  end

  test "full house with 2 three with pair attachments" do
    asserts = {:full_house, 2, 2}
    assert CardRule.check([3, 3, 3, 4, 4, 4, 5, 5, 8, 8], asserts) == {:ok, asserts}
  end

  test "pairs 2 or more pair" do
    assert CardRule.check([3, 3], :pairs) == {:ok, :pairs}
    assert CardRule.check([3, 3, 4, 4], :pairs) == :error
    assert CardRule.check([3, 3, 4, 4, 5, 5], :pairs) == {:ok, :pairs}
  end

  test "straight" do
    assert CardRule.check([4, 5, 6, 7, 8], :straight) == {:ok, :straight}
    assert CardRule.check([4, 5, 6, 7], :straight) == :error
  end
end

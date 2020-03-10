defmodule Raw.Game.CardRuleTest do
  use ExUnit.Case
  alias Raw.Game.CardRule

  test "single card(1)" do
    assert CardRule.check([2]) == {:ok, CardRule.card_type("single")}
  end

  test "one pair(2)" do
    assert CardRule.check([2, 2]) == {:ok, :pairs}
    assert CardRule.check([1, 2]) == {:error}
  end

  test "three of kind(3)" do
    assert CardRule.check([2, 2, 2]) == {:ok, {:full_house, 1, 0}}
    assert CardRule.check([2, 2, 4]) == {:error, "empty keys"}
  end

  test "four cards(4)" do
    assert CardRule.check([2, 2, 2, 1]) == {:ok, {:full_house, 1, 1}}
    assert CardRule.check([2, 2, 2, 2]) == {:ok, :bomb}
    assert CardRule.check([2, 2, 3, 1]) == {:error}
    assert CardRule.check([2, 2, 3, 3]) == {:error}
  end

  test "five cards(5)" do
    assert CardRule.check([2, 2, 2, 2, 1]) == {:error}
    assert CardRule.check([2, 2, 2, 3, 3]) == {:ok, {:full_house, 1, 2}}
    assert CardRule.check([4, 5, 6, 7, 8]) == {:ok, :straight}
  end

  test "six cards(6)" do
    assert CardRule.check([2, 2, 2, 3, 3, 3]) == {:ok, {:full_house, 2, 0}}
    assert CardRule.check([4, 4, 5, 5, 6, 6]) == {:ok, :pairs}
    assert CardRule.check([4, 5, 6, 7, 8, 9]) == {:ok, :straight}
    assert CardRule.check([4, 4, 6, 6, 7, 7]) == {:error}
  end

  test "seven cards(7)" do
    assert CardRule.check([2, 2, 2, 3, 3, 3, 1]) == {:error}
    assert CardRule.check([3, 4, 6, 7, 8, 9, 10]) == {:error}
    assert CardRule.check([3, 4, 5, 6, 7, 8, 9]) == {:ok, :straight}
  end

  test "eight cards(8)" do
    assert CardRule.check([2, 2, 2, 3, 3, 3, 6, 7]) == {:ok, {:full_house, 2, 1}}
    assert CardRule.check([2, 2, 3, 3, 4, 4, 5, 5]) == {:ok, :pairs}
    assert CardRule.check([3, 4, 5, 6, 7, 8, 9, 10]) == {:ok, :straight}
  end
end
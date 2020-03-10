defmodule Raw.Game.CardRuleSelectorTest do
  use ExUnit.Case
  alias Raw.Game.CardRuleSelector

  test "single card(1)" do
    assert CardRuleSelector.select_type([2]) == {:ok, :single}
  end

  test "one pair(2)" do
    assert CardRuleSelector.select_type([2, 2]) == {:ok, :pairs}
    assert CardRuleSelector.select_type([1, 2]) == {:error}
  end

  test "three of kind(3)" do
    assert CardRuleSelector.select_type([2, 2, 2]) == {:ok, {:full_house, 1, 0}}
    assert CardRuleSelector.select_type([2, 2, 4]) == {:error, "empty keys"}
  end

  test "four cards(4)" do
    assert CardRuleSelector.select_type([2, 2, 2, 1]) == {:ok, {:full_house, 1, 1}}
    assert CardRuleSelector.select_type([2, 2, 2, 2]) == {:ok, :bomb}
    assert CardRuleSelector.select_type([2, 2, 3, 1]) == {:error}
    assert CardRuleSelector.select_type([2, 2, 3, 3]) == {:error}
  end

  test "five cards(5)" do
    assert CardRuleSelector.select_type([2, 2, 2, 2, 1]) == {:error}
    assert CardRuleSelector.select_type([2, 2, 2, 3, 3]) == {:ok, {:full_house, 1, 2}}
    assert CardRuleSelector.select_type([4, 5, 6, 7, 8]) == {:ok, :straight}
  end

  test "six cards(6)" do
    assert CardRuleSelector.select_type([2, 2, 2, 3, 3, 3]) == {:ok, {:full_house, 2, 0}}
    assert CardRuleSelector.select_type([4, 4, 5, 5, 6, 6]) == {:ok, :pairs}
    assert CardRuleSelector.select_type([4, 5, 6, 7, 8, 9]) == {:ok, :straight}
    assert CardRuleSelector.select_type([4, 4, 6, 6, 7, 7]) == {:error}
  end

  test "seven cards(7)" do
    assert CardRuleSelector.select_type([2, 2, 2, 3, 3, 3, 1]) == {:error}
    assert CardRuleSelector.select_type([3, 4, 6, 7, 8, 9, 10]) == {:error}
    assert CardRuleSelector.select_type([3, 4, 5, 6, 7, 8, 9]) == {:ok, :straight}
  end

  test "eight cards(8)" do
    assert CardRuleSelector.select_type([2, 2, 2, 3, 3, 3, 6, 7]) == {:ok, {:full_house, 2, 1}}
    assert CardRuleSelector.select_type([2, 2, 3, 3, 4, 4, 5, 5]) == {:ok, :pairs}
    assert CardRuleSelector.select_type([3, 4, 5, 6, 7, 8, 9, 10]) == {:ok, :straight}
  end
end
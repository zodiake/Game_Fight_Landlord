defmodule Card.Game.CardCompareTest do
  @moduledoc false
  use ExUnit.Case
  alias Raw.Game.{CardCompare, CardRuleSelector}

  test "error for single" do
    last = [7]
    current = [6]

    assert CardCompare.basic_compare(current, :single, last) == {:error}
  end

  test "error&success for pair" do
    last = [7, 7]
    current_fail = [6, 6]
    current_success = [10, 10]

    assert CardCompare.basic_compare(current_success, :pairs, last) ==
             {:ok, :pairs}

    assert CardCompare.basic_compare(current_fail, :pairs, last) == {:error}
  end

  test "success for full_house" do
    last = [
      [7, 7, 7],
      [7, 7, 7, 1],
      [7, 7, 7, 1, 1],
      [6, 6, 6, 7, 7, 7],
      [6, 6, 6, 7, 7, 7, 1, 2]
    ]

    current_success = [
      [9, 9, 9],
      [9, 9, 9, 3],
      [9, 9, 9, 3, 3],
      [8, 8, 8, 9, 9, 9],
      [8, 8, 8, 9, 9, 9, 1, 1]
    ]

    for {l, curr} <- Enum.zip(last, current_success) do
      {:ok, meta} = CardRuleSelector.select_type(l)
      assert CardCompare.basic_compare(curr, meta, l) == {:ok, meta}
    end
  end

  test "error for full_house" do
    last = [
      [7, 7, 7],
      [7, 7, 7, 1],
      [7, 7, 7, 1, 1],
      [6, 6, 6, 7, 7, 7],
      [6, 6, 6, 7, 7, 7, 1, 2]
    ]

    current_success = [
      [6, 6, 6],
      [6, 6, 6, 7],
      [6, 6, 6, 3, 3],
      [3, 3, 3, 4, 4, 4],
      [3, 3, 3, 4, 4, 4, 1, 1]
    ]

    for {l, curr} <- Enum.zip(last, current_success) do
      {:ok, meta} = CardRuleSelector.select_type(l)
      assert CardCompare.basic_compare(curr, meta, l) == {:error}
    end
  end

  test "full_house after bomb" do
    last = [3, 3, 3]
    current = [6, 6, 6, 6]

    {:ok, meta} = CardRuleSelector.select_type(last)
    {:ok, type} = CardCompare.basic_compare(current, meta, last)
    assert meta == {:full_house, 1, 0}
    assert type == :bomb
  end
end

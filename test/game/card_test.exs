defmodule Card.Game.CardTest do
  @moduledoc false
  use ExUnit.Case
  alias Raw.Game.Card
  alias Raw.Game.CardSort

  test "card new get 52 card" do
    cards = Card.new()
    assert length(cards) == 54
  end

  test "deal cards" do
    cards = Card.new()

    [f, s, t, left] =
      cards
      |> Card.shuffle()
      |> Card.deal_cards()
    assert length(f) == 17
    assert length(s) == 17
    assert length(t) == 17
    assert length(left) == 3
  end

  test "full house display" do
    assert CardSort.sort([3, 3, 3, 1], {:full_house, 1, 1}) == [3, 3, 3, 1]
    assert CardSort.sort([3, 3, 3, 4], {:full_house, 1, 1}) == [3, 3, 3, 4]
    assert CardSort.sort([2, 2, 2, 3, 3, 3, 10, 10], {:full_house, 2, 1}) == [2, 2, 2, 3, 3, 3, 10, 10]
    assert CardSort.sort([7, 7, 7, 8, 8, 8, 4, 3], {:full_house, 2, 1}) == [7, 7, 7, 8, 8, 8, 3, 4]
  end
end

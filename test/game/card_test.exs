defmodule Card.Game.CardTest do
  @moduledoc false
  use ExUnit.Case
  alias Raw.Game.Card

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
end

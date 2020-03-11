defmodule Card.Game.CardTest do
  @moduledoc false
  use ExUnit.Case
  alias Raw.Game.Card

  test "card new get 52 card" do
    cards = Card.new()
    assert length(cards) == 52
  end
end

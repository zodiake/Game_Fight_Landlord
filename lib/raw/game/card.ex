defmodule Raw.Game.Card do
  @moduledoc false
  alias __MODULE__

  alias Raw.Game.{CardCompare, CardRuleSelector}

  @colors [:splade, :club, :hearts, :diamond]
  @init_cards_num 17
  defstruct [:color, :value, :display_value]

  def new() do
    big_joke = %Card{color: :big_joke, value: 16, display_value: "big_joke"}
    little_joke = %Card{color: :little_joke, value: 17, display_value: "little_joke"}

    cards =
      for c <- @colors,
          v <- 3..15 do
        %Card{}
        |> Map.put(:color, c)
        |> Map.put(:value, v)
        |> Map.put(:display_value, display_value(v))
      end

    [big_joke | [little_joke | cards]]
  end

  def cart_type(cards) do
    CardRuleSelector.select_type(cards)
  end

  def shuffle(cards) do
    Enum.shuffle(cards)
  end

  def deal_cards(cards) do
    first_group = Enum.take(cards, @init_cards_num)
    second_group = cards |> Enum.drop(@init_cards_num) |> Enum.take(@init_cards_num)
    third_group = cards |> Enum.drop(@init_cards_num * 2) |> Enum.take(@init_cards_num)
    landlord_group = cards |> Enum.drop(@init_cards_num * 3) |> Enum.take(3)
    [first_group, second_group, third_group, landlord_group]
  end

  def sort(cards) do
    Enum.sort(cards)
  end

  defp display_value(value) do
    if value <= 13 do
      value
    else
      value - 13
    end
  end

  def extract_card_value(cards) do
    cards |> Enum.map(& &1.value)
  end
end

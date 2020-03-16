defmodule Raw.Game.Card do
  @moduledoc false
  alias __MODULE__

  alias Raw.Game.{CardCompare, CardRuleSelector, CardCompare}

  @type t() :: %Card{color: binary, value: integer, display_value: binary}
  @type list_cards() :: list(Card.t())

  @colors [:splade, :club, :hearts, :diamond]
  @init_cards_num 17
  defstruct [:color, :value, :display_value]

  @spec new() :: list_cards
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

  @spec cart_type(list_cards) :: String.t
  def cart_type(cards) do
    CardRuleSelector.select_type(cards)
  end

  @spec shuffle(list_cards) :: list_cards
  def shuffle(cards) do
    Enum.shuffle(cards)
  end

  @spec deal_cards(list_cards) :: list(list_cards)
  def deal_cards(cards) do
    first_group = Enum.take(cards, @init_cards_num)

    second_group =
      cards
      |> Enum.drop(@init_cards_num)
      |> Enum.take(@init_cards_num)

    third_group =
      cards
      |> Enum.drop(@init_cards_num * 2)
      |> Enum.take(@init_cards_num)

    landlord_group =
      cards
      |> Enum.drop(@init_cards_num * 3)
      |> Enum.take(3)

    [first_group, second_group, third_group, landlord_group]
  end

  @spec sort(list_cards) :: list_cards
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

  @spec extract_card_value({list_cards, list_cards}) :: {list(String.t()), list(String.t())}
  def extract_card_value({this, other}) do
    curr = extract_card_value(this)
    last = extract_card_value(other)
    {curr, last}
  end

  @spec extract_card_value(list_cards) :: list(String.t())
  def extract_card_value(cards) do
    cards
    |> Enum.map(& &1.value)
  end

  @spec compare(tuple(), atom()) :: {atom(), atom()} | atom()
  def compare(tuple, card_type) do
    {curr, last} = extract_card_value(tuple)
    CardCompare.basic_compare(curr, card_type, last)
  end
end

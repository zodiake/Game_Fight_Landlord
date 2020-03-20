defmodule Raw.Game.Card do
  @moduledoc false
  alias __MODULE__

  alias Raw.Game.{CardCompare, CardRuleSelector, CardCompare}
  @spades ["🂣", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪", "🂫", "🂭", "🂮", "🂡", "🂢"]

  @hearts ["🂳", "🂴", "🂵", "🂶", "🂷", "🂸", "🂹", "🂺", "🂻", "🂽", "🂾", "🂱", "🂲"]

  @diamonds ["🃃", "🃄", "🃅", "🃆", "🃇", "🃈", "🃉", "🃊", "🃋", "🃍", "🃎", "🃁", "🃂"]

  @clubs ["🃓", "🃔", "🃕", "🃖", "🃗", "🃘", "🃙", "🃚", "🃛", "🃝", "🃞", "🃑", "🃒"]

  @type t() :: %Card{color: binary, value: integer, display: string}
  @type list_cards() :: list(Card.t())

  @colors [:spade, :club, :heart, :diamond]
  @init_cards_num 17
  defstruct [:color, :value, :display, :class_]

  @spec new() :: list_cards
  def new() do
    big_joke = %Card{color: :big_joke, value: 14, display: "🃏", class_: ""}
    little_joke = %Card{color: :little_joke, value: 15, display: "🃟", class_: ""}

    cards =
      for c <- @colors,
          v <- 0..12 do
        %Card{}
        |> Map.put(:color, c)
        |> Map.put(:value, v)
        |> Map.put(:class_, "")
        |> display_value()
      end

    [big_joke | [little_joke | cards]]
  end

  def display_value(card) do
    display = case card.color do
      :spade ->
        Enum.fetch!(@spades, card.value)
      :heart ->
        Enum.fetch!(@hearts, card.value)
      :club ->
        Enum.fetch!(@clubs, card.value)
      :diamond ->
        Enum.fetch!(@diamonds, card.value)
    end
    %Card{card | display: display}
  end

  @spec cart_type(list_cards) :: String.t()
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

  @spec extract_card_value({list_cards, list_cards}) :: {list(String.t()), list(String.t())}
  defp extract_card_value({this, other}) do
    curr = extract_card_value(this)
    last = extract_card_value(other)
    {curr, last}
  end

  @spec extract_card_value(list_cards) :: list(String.t())
  defp extract_card_value(cards) do
    cards
    |> Enum.map(& &1.value)
  end

  @spec compare(tuple(), atom()) :: {atom(), atom()} | atom()
  def compare(tuple, card_type) do
    {curr, last} = extract_card_value(tuple)
    CardCompare.basic_compare(curr, card_type, last)
  end

  def update_class(card, %{"v" => value, "color" => color}) do
    if to_string(card.value) == value and card.color == String.to_atom(color) do
      IO.inspect(card)
      toggle_selected(card)
    else
      card
    end
  end

  def toggle_selected(card) do
    if card.class_ == "selected" do
      %Card{card | class_: ""}
    else
      %Card{card | class_: "selected"}
    end
  end
end

defmodule Raw.Game.CardRuleSelector do
  alias Raw.Game.Helper

  @pair_check &Helper.pairs_check/1
  @full_house_check &Helper.full_house_check/1
  @bomb_check &Helper.is_bomb/1
  @straight_check &Helper.straight_check/1

  # check straight
  def select_type(cards) when length(cards) == 1 do
    {:ok, :single}
  end

  def select_type(cards) when length(cards) == 2 do
    @pair_check.(cards)
  end

  def select_type(cards) when length(cards) == 3 do
    case @full_house_check.(cards) do
      {:ok, meta} when meta == {:full_house, 1, 0} ->
        {:ok, meta}

      _ ->
        :error
    end
  end

  def select_type(cards) when length(cards) == 4 do
    select_from_types(cards, [@bomb_check, @full_house_check])
  end

  def select_type(cards) when length(cards) == 5 do
    select_from_types(cards, [@straight_check, @full_house_check])
  end

  def select_type(cards) when rem(length(cards), 2) == 0 and length(cards) >= 6 do
    select_from_types(cards, [@straight_check, @full_house_check, @pair_check])
  end

  def select_type(cards) do
    @straight_check.(cards)
  end

  def select_from_types(cards, rule_list) do
    filtered =
      rule_list
      |> Enum.map(fn f -> f.(cards) end)
      |> Enum.filter(&(&1 != :error))

    if length(filtered) > 0 do
      hd(filtered)
    else
      :error
    end
  end
end

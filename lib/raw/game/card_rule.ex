defmodule Raw.Game.CardRule do
  alias Raw.Game.Helper

  @basic_card_types %{
    "straight" => :straight,
    "single" => :single,
    "pairs" => :pairs,
    "bomb" => :bomb,
    "full_house" => :full_house
  }

  def card_type(index) do
    Map.get(@basic_card_types, index)
  end

  # check straight
  def check(cards) when length(cards) == 1 do
    {:ok, card_type("single")}
  end

  def check(cards) when length(cards) == 2 do
    cards
    |> Helper.pairs_check()
  end

  def check(cards) when length(cards) == 3 do
    with {:ok, meta_data} <- Helper.full_house_check(cards) do
      if meta_data == {:full_house, 1, 0} do
        {:ok, meta_data}
      else
        {:error}
      end
    else
      {:error, msg} -> {:error, msg}
    end
  end

  def check(cards) when length(cards) == 4 do
    full_house = &Helper.full_house_check(&1)
    bomb = &Helper.all_eq(&1, card_type("bomb"))
    filter_rules(cards, [bomb, full_house])
  end

  def check(cards) when length(cards) == 5 do
    full_house = &Helper.full_house_check(&1)
    filter_rules(cards, [&straight/1, full_house])
  end

  def check(cards) when rem(length(cards), 2) == 0 and length(cards) >= 6 do
    full_house_check = &Helper.full_house_check(&1)
    multi_pair_check = &Helper.pairs_check(&1)
    filter_rules(cards, [&straight/1, full_house_check, multi_pair_check])
  end

  def check(cards) do
    case straight(cards) do
      {:ok, :straight} -> {:ok, :straight}
      {:error} -> {:error}
    end
  end

  def filter_rules(cards, rule_list) do
    filtered =
      rule_list
      |> Enum.map(fn f -> f.(cards) end)
      |> Enum.filter(fn x -> elem(x, 0) == :ok end)

    if length(filtered) > 0 do
      hd(filtered)
    else
      {:error}
    end
  end

  def straight(cards) do
    result = Helper.diff_one(cards)

    if result == {:ok} do
      {:ok, :straight}
    else
      {:error}
    end
  end
end

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

  def basic_card_type(index) do
    Enum.fetch(@basic_card_types, index)
  end

  #check straight
  def check(cards) when length(cards) == 1 do
    {:ok, card_type("single")}
  end

  def check(cards) when length(cards) == 2 do
    card_type = card_type("one_pair")
    if Helper.all_eq(cards, card_type) == {:ok, card_type} do
      {:ok, card_type}
    else
      {:error}
    end
  end

  def check(cards) when length(cards) == 3 do
    card_type = card_type("three_of_kind")
    if Helper.all_eq(cards, card_type) == {:ok, card_type} do
      {:ok, card_type}
    else
      {:error}
    end
  end

  def check(cards) when length(cards) == 4 do
    full_house = &Helper.full_house_check(&1)
    bomb = &Helper.all_eq(&1, card_type("bomb"))
    filter_rules(cards, [bomb, full_house])
  end

  def check(cards) when length(cards) == 5 do
    full_house2 = &Helper.full_house_check(&1)
    filter_rules(cards, [&straight/1, full_house2])
  end

  def check(cards) when length(cards) == 6 do
    full_house_check = &Helper.full_house_check(&1)
    multi_pair_check = &Helper.one_pairs_check(&1)
    filter_rules(cards, [&straight/1, full_house_check, multi_pair_check])
  end

  def check(cards) do
    case straight(cards) do
      true -> {:ok, :straight}
      false -> {:error}
    end
  end

  def filter_rules(cards, rule_list) do
    filtered = rule_list
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

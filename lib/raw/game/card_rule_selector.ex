defmodule Raw.Game.CardRuleSelector do
  alias Raw.Game.Helper

  # check straight
  def select_type(cards) when length(cards) == 1 do
    {:ok, :single}
  end

  def select_type(cards) when length(cards) == 2 do
    cards
    |> Helper.pairs_check()
  end

  def select_type(cards) when length(cards) == 3 do
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

  def select_type(cards) when length(cards) == 4 do
    full_house = &Helper.full_house_check(&1)
    bomb = &Helper.all_eq(&1, :bomb)
    select_from_types(cards, [bomb, full_house])
  end

  def select_type(cards) when length(cards) == 5 do
    full_house = &Helper.full_house_check(&1)
    select_from_types(cards, [&straight/1, full_house])
  end

  def select_type(cards) when rem(length(cards), 2) == 0 and length(cards) >= 6 do
    full_house_check = &Helper.full_house_check(&1)
    multi_pair_check = &Helper.pairs_check(&1)
    select_from_types(cards, [&straight/1, full_house_check, multi_pair_check])
  end

  def select_type(cards) do
    case straight(cards) do
      {:ok, :straight} -> {:ok, :straight}
      {:error} -> {:error}
    end
  end

  def select_from_types(cards, rule_list) do
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

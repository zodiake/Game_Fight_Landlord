defmodule Raw.Game.CardCompare do
  @moduledoc false
  alias Raw.Game.{CardTypeCheck, Helper}

  def compare(curr_cards, :single, last_cards) do
    if hd(last_cards) < hd(curr_cards) do
      {:ok, :single, curr_cards}
    else
      {:error}
    end
  end

  def compare(cards, :straight, last) do
    if length(last) != length(cards) or hd(last) >= hd(cards) do
      {:error}
    else
      {:ok, :straight, cards}
    end
  end

  def compare(cards, {:full_house, a, b}, last) do
    last_keys =
      last
      |> Enum.group_by(fn x -> x end)
      |> Enum.filter(fn {_k, v} -> length(v) == 3 end)

    current_keys =
      cards
      |> Enum.group_by(fn x -> x end)
      |> Enum.filter(fn {_k, v} -> length(v) == 3 end)

    if hd(current_keys) < hd(last_keys) do
      {:error}
    else
      {:ok, {:full_house, a, b}, cards}
    end
  end

  def compare(cards, :bomb, last) do
    if hd(cards) > hd(last) do
      {:ok, :bomb, cards}
    else
      {:error}
    end
  end

  def compare(cards, :pairs, last) do
    if length(last) != length(cards) or hd(last) >= hd(cards) do
      {:error}
    else
      {:ok, :pairs, cards}
    end
  end

  def basic_compare(_current, _type, last) when length(last) == 0 do
    with {:ok, type} <- CardTypeCheck.check(_type, _current) do
      {:ok, type, _current}
    else
      {:error} -> {:error, "seems not meet rule"}
      {:error, msg} -> {:error, msg}
    end
  end

  def basic_compare(cards, type, last) when type == :bomb do
    compared_res = compare(type, last, cards)
    expected = {:ok, :bomb, cards}

    if Helper.is_bomb(cards) == {:ok} and compared_res == expected do
      expected
    else
      {:error}
    end
  end

  def basic_compare(cards, type, last) do
    if Helper.is_bomb(cards) == {:ok} do
      {:ok, :bomb, cards}
    else
      compare(cards, type, last)
    end
  end
end

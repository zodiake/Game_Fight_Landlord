defmodule Raw.Game.CardCompare do
  @moduledoc false
  alias Raw.Game.{CardRule, Helper, Card}

  @spec compare(curr_cards :: list(integer), atom(), last_cards :: list(integer)) ::
          {atom(), atom()} | atom()
  def compare(curr_cards, :single, last_cards) do
    if hd(last_cards) < hd(curr_cards) do
      {:ok, :single}
    else
      :error
    end
  end

  def compare(cards, :straight, last) do
    if length(last) != length(cards) or hd(last) >= hd(cards) do
      :error
    else
      {:ok, :straight}
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
      :error
    else
      {:ok, {:full_house, a, b}}
    end
  end

  def compare(cards, :bomb, last) do
    if hd(cards) > hd(last) do
      {:ok, :bomb}
    else
      {:error}
    end
  end

  def compare(cards, :pairs, last) do
    if length(last) != length(cards) or hd(last) >= hd(cards) do
      :error
    else
      {:ok, :pairs}
    end
  end

  @spec basic_compare(Card.list_cards, atom, Card.list_cards) :: {:ok, atom} | :error
  def basic_compare(current, type, last) when length(last) == 0 do
    with {:ok, new_type} <- CardRule.check(current, type) do
      {:ok, new_type}
    else
      :error -> :error
      {:error, _msg} -> :error
    end
  end

  def basic_compare(cards, type, last) do
    if Helper.is_bomb(cards) == :error do
      compare(cards, type, last)
    else
      if type == :bomb do
        compare(cards, :bomb, last)
      else
        {:ok, :bomb}
      end
    end
  end
end

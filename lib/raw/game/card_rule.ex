defmodule Raw.Game.CardRule do
  @moduledoc false
  alias Raw.Game.Helper

  def check(cards, :single) do
    if length(cards) == 1 do
      {:ok, :single}
    else
      {:error}
    end
  end

  def check(cards, :pairs) do
    result = Helper.pairs_check(cards)

    if elem(result, 0) == :ok do
      {:ok, :pairs}
    else
      {:error}
    end
  end

  def check(cards, {:full_house, a, b}) do
    with {:ok, {:full_house, c, d}} <- Helper.full_house_check(cards) do
      if a == c and b == d do
        {:ok, {:full_house, a, b}}
      else
        {:error}
      end
    else
      {:error} -> {:error}
      {:error, msg} -> {:error, msg}
    end
  end

  def check(cards, :straight) do
    if elem(Helper.diff_one(cards), 0) == {:error} or length(cards) < 5 do
      {:error}
    else
      {:ok, :straight}
    end
  end
end

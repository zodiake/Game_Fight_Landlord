defmodule Raw.Game.CardRule do
  @moduledoc false
  alias Raw.Game.Helper

  def check(cards, :single) do
    if length(cards) == 1 do
      {:ok, :single}
    else
      :error
    end
  end

  def check(cards, :pairs) do
    result = Helper.pairs_check(cards)

    case Helper.pairs_check(cards) do
      :error -> :error
      {:ok, :pairs} -> {:ok, :pairs}
    end
  end

  def check(cards, {:full_house, a, b}) do
    with {:ok, {:full_house, c, d}} <- Helper.full_house_check(cards) do
      if a == c and b == d do
        {:ok, {:full_house, a, b}}
      else
        :error
      end
    else
      {:error} -> :error
      {:error, msg} -> :error
    end
  end

  def check(cards, :straight) do
    if Helper.diff_one(cards) == :error or length(cards) < 5 do
      :error
    else
      {:ok, :straight}
    end
  end
end

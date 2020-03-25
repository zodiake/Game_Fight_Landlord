defmodule Raw.Game.CardRule do
  @moduledoc false
  alias Raw.Game.Helper

  def check(cards, :single) when length(cards) == 1 do
    {:ok, :single}
  end

  def check(cards, :pairs) when div(length(cards), 2) == 0 do
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
      :error -> :error
      {:error, _msg} -> :error
    end
  end

  def check(cards, :straight) do
    if Helper.diff_one(cards) == false or length(cards) < 5 do
      :error
    else
      {:ok, :straight}
    end
  end
end

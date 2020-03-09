defmodule Raw.Game.CardSort do
  alias Hello.CardRule
  def sort(cards) when length(cards) == 5 do
    sorted = Enum.sort(cards)
    if CardRule.diff_one(sorted) == :ok  do
      sorted
    else
      if CardRule.all_eq(Enum.take(sorted, 3)) do
        sorted
      else
        sorted = Enum.drop(sorted, 2) ++ Enum.take(sorted, 2)
      end
    end
  end

  def sort(cards) do
    cards
  end
end

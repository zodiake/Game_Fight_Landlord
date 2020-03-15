defmodule Raw.Game.CardSort do
  alias Raw.Game.Helper

  def sort(cards, meta) do
    case meta do
      {:full_house, _a, _b} ->
        grouped = Enum.group_by(cards, & &1)
        three_v = Keyword.values(Enum.filter(grouped, fn {_k, v} -> length(v) == 3 end))
        two_v = Keyword.values(Enum.filter(grouped, fn {_k, v} -> length(v) != 3 end))
        Enum.reduce(Enum.sort(three_v) ++ Enum.sort(two_v), fn x, acc -> acc ++ x end)
      _ ->
        cards
    end
  end
end

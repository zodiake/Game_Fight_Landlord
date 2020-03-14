defmodule Raw.Game.Helper do
  def diff_one(cards) when length(cards) < 2 do
    true
  end

  def diff_one(cards) do
    if Enum.all?(Enum.map(Enum.zip(cards, tl(cards)), fn {f, s} -> s - f end), &(&1 == 1)) do
      true
    else
      false
    end
  end

  def all_eq(cards) when length(cards) > 0 do
    head = hd(cards)

    if Enum.all?(tl(cards), fn x -> x == head end) do
      :ok
    else
      :error
    end
  end

  def group_by_key(seq) do
    seq
    |> Enum.group_by(fn x -> x end)
  end

  def value_length(map) do
    map
    |> Enum.map(fn {_k, v} -> length(v) end)
  end

  def is_bomb(cards) when length(cards) == 4 do
    case all_eq(cards) do
      :ok -> {:ok, :bomb}
      :error -> :error
    end
  end

  def is_bomb(cards)  do
    :error
  end

  def pairs_check(cards) do
    grouped = group_by_key(cards)
    keys = Map.keys(grouped)
    values = Map.values(grouped)

    if length(keys) >= 3 or length(keys) == 1 do
      with true <- diff_one(keys),
           true <- Enum.all?(values, &(length(&1) == 2)) do
        {:ok, :pairs}
      else
        false -> :error
      end
    else
      :error
    end
  end

  def straight_check(cards) do
    case diff_one(cards) do
      true -> {:ok, :straight}
      false -> :error
    end
  end

  def keys_and_values(dict) do
    {
      dict
      |> Map.keys(),
      dict
      |> Map.values()
    }
  end

  def full_house_check(cards) do
    grouped = group_by_key(cards)

    three_keys =
      grouped
      |> Enum.filter(fn {_k, v} -> length(v) == 3 end)
      |> Keyword.keys()

    left_grouped =
      grouped
      |> Enum.filter(fn {_k, v} -> length(v) != 3 end)
      |> Enum.into(%{})

    left_values =
      left_grouped
      |> Map.values()
      |> List.flatten()

    left_keys =
      left_grouped
      |> Map.keys()

    with true <- diff_one(three_keys),
         :ok <- three_other_keys_can_pair(three_keys, left_keys, left_values) do
      if length(left_keys) == 0 do
        {:ok, {:full_house, length(three_keys), 0}}
      else
        {:ok, {:full_house, length(three_keys), div(length(left_values), length(three_keys))}}
      end
    else
      false -> :error
      :error -> :error
    end
  end

  defp three_other_keys_can_pair(three_keys, other_keys, other_values) do
    # attach card or do not attach card or attach card number is equal to three group count
    if length(three_keys) == length(other_keys) || length(other_keys) == 0 ||
         length(other_values) == length(three_keys) do
      :ok
    else
      :error
    end
  end

  defp get_value_length(maps, keys) do
    length(Map.fetch!(maps, hd(keys)))
  end
end

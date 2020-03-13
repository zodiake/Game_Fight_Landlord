defmodule Raw.Game.Helper do
  @card_type %{
    [3] => :full_house,
    [1, 3] => :full_house1,
    [2, 3] => :full_house2
  }

  # shunzi
  def diff_one(cards) do
    tail = tl(cards)

    if tail == nil do
      {:ok}
    end

    if Enum.all?(Enum.map(Enum.zip(cards, tail), fn {f, s} -> s - f end), fn x -> x == 1 end) do
      {:ok}
    else
      {:error, "seems not straight"}
    end
  end

  def all_eq(cards) when length(cards) > 0 do
    head = hd(cards)

    if Enum.all?(tl(cards), fn x -> x == head end) do
      {:ok}
    else
      {:error}
    end
  end

  def all_eq(cards, card_type) do
    if all_eq(cards) == {:ok} do
      {:ok, card_type}
    else
      {:error}
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

  def is_bomb(cards) do
    if length(cards) == 4 and all_eq(cards) == {:ok} do
      {:ok}
    else
      {:error}
    end
  end

  def pairs_check(cards) do
    grouped = group_by_key(cards)
    keys = Map.keys(grouped)
    values = Map.values(grouped)

    if length(keys) >= 3 or length(keys) == 1 do
      with {:ok} <- diff_one(keys),
           true <- Enum.all?(values, fn x -> length(x) == 2 end) do
        {:ok, :pairs}
      else
        {:error, msg} -> {:error, msg}
        false -> {:error, "not all one_pair"}
      end
    else
      {:error}
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

    with {:ok} <- length_diff_check(three_keys),
         {:ok} <- three_other_keys_can_pair(three_keys, left_keys, left_values) do
      if length(left_keys) == 0 do
        {:ok, {:full_house, length(three_keys), 0}}
      else
        {:ok, {:full_house, length(three_keys), div(length(left_values), length(three_keys))}}
      end
    else
      {:error, msg} -> {:error, msg}
    end
  end

  defp length_diff_check(keys) when length(keys) == 1 do
    {:ok}
  end

  defp length_diff_check(keys) when length(keys) > 1 do
    if diff_one(keys) == {:ok} do
      {:ok}
    else
      {:error, "do not has a three pair"}
    end
  end

  defp length_diff_check(_) do
    {:error, "empty keys"}
  end

  defp three_other_keys_can_pair(three_keys, other_keys, other_values) do
    # attach card or do not attach card or attach card number is equal to three group count
    if length(three_keys) == length(other_keys) || length(other_keys) == 0 ||
         length(other_values) == length(three_keys) do
      {:ok}
    else
      {:error, "can not pair"}
    end
  end

  defp get_value_length(maps, keys) do
    length(Map.fetch!(maps, hd(keys)))
  end

end

defmodule Raw.Game.Helper do
  @card_type %{
    [3] => :full_house,
    [1, 3] => :full_house1,
    [2, 3] => :full_house2,
  }

  #shunzi
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

  def one_pairs_check(cards) do
    grouped = group_by_key(cards)
    keys = Map.keys(grouped)
    values = Map.values(grouped)

    if length(keys) < 3 do
      {:error}
    else
      with {:ok} <- diff_one(keys),
           true <- Enum.all?(values, fn x -> length(x) == 2 end) do
        {:ok, :pairs, length(keys)}
      else
        {:error, msg} -> {:error, msg}
        false -> {:error, "not all one_pair"}
      end
    end

  end

  def full_house_check(cards) do
    grouped = group_by_key(cards)
    three_keys = grouped
                 |> Enum.filter(fn {_k, v} -> length(v) == 3 end)
                 |> Enum.into(%{})
                 |> Map.keys()

    left_grouped = grouped
                   |> Enum.filter(fn {_k, v} -> length(v) != 3 end)
                   |> Enum.into(%{})
    left_keys = left_grouped
                |> Map.keys()

    with {:ok} <- at_least_has_one_three(three_keys),
         {:ok} <- three_other_keys_can_pair(three_keys, left_keys) do
      if length(left_keys) == 0 do
        {:ok, :full_house, length(three_keys), 0}
      else
        {:ok, :full_house, length(three_keys), get_value_length(left_grouped, left_keys)}
      end
    else
      {:error, msg} -> {:error, msg}
    end
  end

  defp at_least_has_one_three(keys) do
    if length(keys) >= 1 and diff_one(keys) == {:ok} do
      {:ok}
    else
      {:error, "do not has a three pair"}
    end
  end

  defp three_other_keys_can_pair(three_keys, other_keys) do
    if length(three_keys) == length(other_keys) || length(other_keys) == 0 do
      {:ok}
    else
      {:error, "can not pair"}
    end
  end

  defp get_value_length(maps, keys) do
    length(Map.fetch!(maps, hd(keys)))
  end
end
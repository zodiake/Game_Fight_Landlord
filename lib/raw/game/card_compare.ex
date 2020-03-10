defmodule Raw.Game.CardCompare do
  @moduledoc false
  alias Raw.Game.{CardTypeCheck, Helper}

  def compare(:single, last, current) do
    if hd(last) < hd(current) do
      {:ok, :single, current}
    else
      {:error}
    end
  end

  def compare(:straight, last, current) do
    if length(last) != length(current) or hd(last) >= hd(current) do
      {:error}
    else
      {:ok, :straight, current}
    end
  end

  def compare({:full_house, a, b}, last, current) do
    last_keys =
      last
      |> Enum.group_by(fn x -> x end)
      |> Enum.filter(fn {_k, v} -> length(v) == 3 end)

    current_keys =
      current
      |> Enum.group_by(fn x -> x end)
      |> Enum.filter(fn {_k, v} -> length(v) == 3 end)

    if hd(current_keys) < hd(last_keys) do
      {:error}
    else
      {:ok, {:full_house, a, b}, current}
    end
  end

  def compare(:bomb, last, current) do
    if hd(current) > hd(last) do
      {:ok, :bomb, current}
    else
      {:error}
    end
  end

  def compare(:pairs, last, current) do
    if length(last) != length(current) or hd(last) >= hd(current) do
      {:error}
    else
      {:ok, :pairs, current}
    end
  end

  def basic_compare(_type, last, _current) when length(last) == 0 do
    with {:ok, type} <- CardTypeCheck.check(_type, _current) do
      {:ok, type, _current}
    else
      {:error} -> {:error, "seems not meet rule"}
      {:error, msg} -> {:error, msg}
    end
  end

  def basic_compare(type, last, current) when type == :bomb do
    compared_res = compare(type, last, current)
    expected = {:ok, :bomb, current}

    if Helper.is_bomb(current) == {:ok} and compared_res == expected do
      expected
    else
      {:error}
    end
  end

  def basic_compare(type, last, current) do
    if Helper.is_bomb(current) == {:ok} do
      {:ok, :bomb, current}
    else
      compare(type, last, current)
    end
  end
end

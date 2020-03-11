defmodule Raw.Game.Card do
  @moduledoc false
  alias __MODULE__

  @colors [:splade, :club, :hearts, :diamond]
  defstruct [:color, :value, :display_value]

  def new() do
    for c <- @colors,
        v <- 3..15 do
      %Card{}
      |> Map.put(:color, c)
      |> Map.put(:value, v)
      |> Map.put(:display_value, display_value(v))
    end
  end

  defp display_value(value) do
    if value <= 13 do
      value
    else
      value - 13
    end
  end
end

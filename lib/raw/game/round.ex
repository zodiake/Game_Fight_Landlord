defmodule Raw.Game.Round do
  defstruct last: [],
            first_hand: nil,
            turn: []
  def update_first_hand(round, player), do: %__MODULE__{round | first_hand: player}
end
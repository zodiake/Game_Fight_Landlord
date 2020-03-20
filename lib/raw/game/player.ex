defmodule Raw.Game.Player do
  defstruct name: "",
            hands: []

  @type t() :: %__MODULE__{name: binary, hands: List.t()}
  def add_hands(player, cards) do
    new_hands = cards ++ player.hands
    %__MODULE__{player | hands: new_hands}
  end
end
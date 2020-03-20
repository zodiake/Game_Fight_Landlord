defmodule Raw.Game.Player do
  defstruct name: "",
            hands: []

  def add_hands(player, cards)do
    new_hands = cards ++ player.hands
    %__MODULE__{player | hands: new_hands}
  end
end
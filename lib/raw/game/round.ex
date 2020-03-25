defmodule Raw.Game.Round do
  alias Raw.Game.{Card, CardRuleSelector}

  defstruct turn: nil,
            round_history: []

  def update_turn(round, player), do: %__MODULE__{round | turn: player}

  def add_round_history(round, p, cards) do
    %__MODULE__{
      round
      | round_history: [
          %{player: p, cards: cards, type: CardRuleSelector.select_type(cards)}
          | round.round_history
        ]
    }
  end
end

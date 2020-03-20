defmodule Raw.Game.GameState do
  alias Raw.Game.{GameRule, Card, Player}

  defstruct id: nil,
            player1: %Player{},
            player2: %Player{},
            player3: %Player{},
            landlord: %Player{},
            rule: %GameRule{},
            last_round: nil

  @players [:player1, :player2, :player3]

  def new(id) do
    %__MODULE__{%__MODULE__{} | id: id}
  end

  def player_joined(state) do
    case GameRule.check(state.rule, :add_player) do
      {:ok, player, rule} ->
        {:ok, player, update_rule(state, rule)}

      :error ->
        {:error, state}
    end
  end

  def player_ready(state, player) do
    case GameRule.check(state.rule, {:get_ready, player}) do
      {:ok, rule} ->
        if rule.rule_state == :landlord_electing do
          [f, s, t, l] = Card.deal_cards(Card.new())

          ns =
            state
            |> update_rule(rule)
            |> add_player_cards(:player1, f)
            |> add_player_cards(:player2, s)
            |> add_player_cards(:player3, t)
            |> add_player_cards(:landlord, l)

          {:ok, ns}
        else
          ns =
            state
            |> update_rule(rule)

          {:ok, ns}
        end

      _ ->
        {:error, state}
    end
  end

  defp update_rule(state, rule), do: %__MODULE__{state | rule: rule}

  defp add_player_cards(state, player, cards) do
    p =
      state
      |> Map.fetch!(player)
      |> Player.add_hands(cards)

    Map.put(state, player, p)
  end
end

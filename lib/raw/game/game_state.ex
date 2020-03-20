defmodule Raw.Game.GameState do
  alias Raw.Game.{GameRule, Card, Player}
  @type t() :: %__MODULE__{id: integer}

  defstruct id: nil,
            player0: %Player{},
            player1: %Player{},
            player2: %Player{},
            landlord: %Player{},
            rule: %GameRule{},
            last_round: nil

  @players [:player0, :player1, :player2]

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
          state |> deal_cards(rule) |> success
        else
          state
          |> update_rule(rule)
          |> success()
        end

      _ ->
        {:error, state}
    end
  end

  def accept_landlord(state, player) do
    case GameRule.check(state.rule, {:accept_landlord, player}) do
      :error ->
        state |> fail()

      {:ok, rule} ->
        state |> update_rule(rule) |> add_player_cards(player, state.extra_cards) |> success()
    end
  end

  def pass_landlord(state, player) do
    case GameRule.check(state.rule, {:pass_landlord, player}) do
      :error ->
        state |> fail()

      {:ok, player, rule} ->
        {:ok, player, state |> update_rule(rule)}

      {:ok, rule} ->
        {:ok, state |> update_rule(rule)}
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

  defp deal_cards(state, rule) do
    [f, s, t, l] = Card.deal_cards(Card.new())

    state
    |> update_rule(rule)
    |> add_player_cards(:player0, f)
    |> add_player_cards(:player1, s)
    |> add_player_cards(:player2, t)
    |> Map.put(:extra_cards, l)
  end

  defp success(state) do
    {:ok, state}
  end

  defp fail(state) do
    {:error, state}
  end
end

defmodule Raw.Game.GameState do
  alias Raw.Game.{GameRule, Card, Player, Round}
  require Logger
  @type t() :: %__MODULE__{id: integer}

  defstruct id: nil,
            players: [player0: %Player{}, player1: %Player{}, player2: %Player{}],
            extra_cards: nil,
            rule: %GameRule{}

  @players [:player0, :player1, :player2]

  def new(id) do
    %__MODULE__{%__MODULE__{} | id: id}
  end

  def update_state(state, :player_join) do
    case GameRule.check(state.rule, :add_player) do
      {:ok, player, rule} ->
        {:ok, player, state |> update_rule(rule)}

      :error ->
        :error
    end
  end

  def update_players(state, players) do
    %__MODULE__{state | players: players}
  end

  def update_player(state, player, np) do
    Keyword.update!(state.players, player, np)
  end

  def add_player_cards(state, player, cards) do
    players =
      Keyword.update!(
        state.players,
        player,
        fn x -> Player.add_hands(x, cards) end
      )

    update_players(state, players)
  end

  def deal_cards(state) do
    [f, s, t, e] =
      Card.new()
      |> Card.shuffle()
      |> Card.deal_cards()

    {e,
     state.players
     |> Enum.zip([f, s, t])
     |> Enum.map(fn {{key, player}, cards} -> {key, Player.add_hands(player, cards)} end)}
  end

  def update_extra_cards(state, extra) do
    %__MODULE__{state | extra_cards: extra}
  end

  def player_ready(state, player) do
    case GameRule.check(state.rule, {:get_ready, player}) do
      {:ok, rule} ->
        if rule.rule_state == :landlord_electing do
          state
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

      {:ok, rule} ->
        {:ok, rule.landlord, state |> update_rule(rule)}

      {:restart, rule} ->
        {:restart, state |> update_rule(rule)}
    end
  end

  def update_rule(state, rule), do: %__MODULE__{state | rule: rule}

  defp success(state) do
    {:ok, state}
  end

  defp fail(state) do
    {:error, state}
  end
end

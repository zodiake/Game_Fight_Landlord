defmodule Raw.Game.GameEngine do
  use GenServer
  alias Raw.Game.{Card, GameRule, CardRuleSelector, CardCompare, GameState}

  def start_link(guid) do
    GenServer.start_link(__MODULE__, guid, name: via(guid))
  end

  def init(params) do
    {:ok, GameState.new(params)}
  end

  def via(name), do: {:via, Registry, {Registry.Game, name}}

  def player_join(game), do: GenServer.call(game, :add_player)

  def player_get_ready(game, player), do: GenServer.call(game, {:get_ready, player})

  def pass_landlord(game, player),
    do: GenServer.call(game, {:pass_landlord, player})

  def accept_landlord(game, player),
    do: GenServer.call(game, {:accept_landlord, player})

  def play_round(game, player, cards), do: GenServer.call(game, {:play, player, cards})

  def pass_round(game, player), do: GenServer.call(game, {:pass, player})

  def handle_call(:add_player, _from, state) do
    case GameRule.check(state.rule, :add_player) do
      {:ok, player, rule} ->
        {
          :reply,
          player,
          state
          |> GameState.update_rule(rule)
        }

      :error ->
        {:reply, :error, state}
    end
  end

  def handle_call({:get_ready, player}, _from, state) do
    case GameRule.check(state.rule, {:get_ready, player}) do
      {:ok, rule} ->
        if rule.rule_state == :landlord_electing do
          {e, players} = GameState.deal_cards(state)

          hand_cards_extra_landlord =
            {Enum.map(players, fn {k, v} -> {k, v.hands} end), e, rule.landlord}

          {
            :reply,
            hand_cards_extra_landlord,
            state
            |> GameState.update_rule(rule)
            |> GameState.update_players(players)
            |> GameState.update_extra_cards(e)
          }
        else
          {
            :reply,
            :ok,
            state
            |> GameState.update_rule(rule)
          }
        end

      :error ->
        {:reply, :error, state}
    end
  end

  def handle_call({:accept_landlord, player}, _from, state) do
    case GameRule.check(state.rule, {:accept_landlord, player}) do
      :error ->
        {:reply, :error, state}

      {:ok, rule} ->
        state
        |> GameState.update_rule(rule)
        |> GameState.add_player_cards(player, state.extra_cards)
        |> reply_success(&Enum.map(&1.players, fn {k, v} -> {k, v.hands} end))
    end
  end

  def handle_call({:pass_landlord, player}, _from, state) do
    case GameRule.check(state.rule, {:pass_landlord, player}) do
      {:restart, rule} ->
        {
          :reply,
          :restart,
          state
          |> GameState.update_rule(rule)
        }

      {:ok, rule} ->
        {
          :reply,
          rule.landlord,
          state
          |> GameState.update_rule(rule)
        }
    end
  end

  def handle_call({:play, player, cards}, _from, state) do
    case CardRuleSelector.select_type(cards) do
      :error ->
        {:reply, :error, state}

      {:ok, type} ->
        GameRule.check(state.rule, {:play, player, cards})
    end
  end

  def handle_call({:pass, player}, _from, state) do
    case GameRule.check(state.rules, {:pass, player}) do
      {:ok, rules, :round_over} ->
        state
        |> GameState.update_rule(rules)
        |> clear_last()
        |> reply_success(rules.state)

      {:ok, rules} ->
        state
        |> GameState.update_rule(rules)
        |> reply_success(rules.state)

      :error ->
        {:reply, :error, state}
    end
  end

  defp maybe_join(state, {:ok, player, state}), do: {:reply, {:ok, player}, state}

  defp maybe_join({:error, state}), do: {:reply, :error, state}

  defp maybe_ready({:ok, state}) do
    if state.rule.rule_state == :landlord_electing do
      state
      |> reply_success(
        player0: state.player0.hands,
        player1: state.player1.hands,
        player2: state.player2.hands,
        landlord: state.rule.landlord,
        extra_cards: state.extra_cards
      )
    else
      {:reply, :ok, state}
    end
  end

  defp maybe_ready({:error, state}), do: {:reply, :error, state}

  defp maybe_accept({:error, state}), do: {:reply, :error, state}

  defp maybe_accept({:ok, state}), do: {:reply, state.rule.round.turn, state}

  defp maybe_pass({:error, state}), do: {:reply, :error, state}

  defp maybe_pass({:ok, player, state}), do: {:reply, player, state}

  defp maybe_pass({:restart, state}), do: {:reply, :restart, state}

  def reply_success(state, reply), do: {:reply, reply.(state), state}

  def reply_success(state), do: {:reply, state, state}

  def sort_hands(state, player) do
    cards = get_in(state, [player, :hands])
    put_in(state, [player, :hands], Enum.sort_by(cards, fn x -> x.value end))
  end

  def update_last_cards_and_type(state, cards, meta) do
    last = %{state.last | card: cards, meta: meta}
    %{state | last: last}
  end

  def remove_hands(state, player, cards) do
    new_hands = Enum.filter(get_in(state, [player, :hands]), fn x -> !Enum.member?(cards, x) end)
    put_in(state, [player, :hands], new_hands)
  end

  def clear_last(state) do
    last = %{state.last | card: nil, meta: nil}
    %{state | last: last}
  end

  defp update_player_hands(state, [f, s, t, e]) do
    Enum.zip(state.players)
  end
end

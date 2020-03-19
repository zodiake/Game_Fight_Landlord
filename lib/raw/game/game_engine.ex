defmodule Raw.Game.GameEngine do
  use GenServer
  alias Raw.Game.{Card, GameRule, CardRuleSelector, CardCompare}

  def start_link(guid) do
    GenServer.start_link(__MODULE__, guid, name: via(guid))
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
    with {:ok, player, rules} <- GameRule.check(state.rules, :add_player) do
      state
      |> update_rules(rules)
      |> reply_success(player)
    else
      :error -> {:reply, :error, state}
    end
  end

  def handle_call({:get_ready, player}, _from, state) do
    case GameRule.check(state.rules, {:get_ready, player}) do
      {:ok, rules} ->
        if rules.state == :deal_cards do
          state
          |> deal_cards(rules)
          |> deal_finished()
          |> reply_success()

        else
          state
          |> update_rules(rules)
          |> reply_success(:ok)
        end

      _ ->
        {:reply, :error, state}
    end
  end

  def handle_call({:pass_landlord, player}, _from, state) do
    with {:ok, next_one, rules} <- GameRule.check(state.rules, {:pass_landlord, player}) do
      state
      |> update_rules(rules)
      |> reply_success(next_one)
    else
      :error -> {:reply, :error, state}
    end
  end

  def handle_call({:accept_landlord, player}, _from, state) do
    with {:ok, rules} <- GameRule.check(state.rules, {:accept_landlord, player}) do
      state
      |> update_rules(rules)
      |> add_hands(player, state.landlord_cards.hands)
      |> reply_success()
    end
  end

  def handle_call({:play, player, cards}, _from, state) do
    case state.last.card do
      nil ->
        with {:ok, meta} <-
               CardRuleSelector.select_type(
                 cards
                 |> Card.extract_card_value()
               ),
             {:ok, new_rule} <- GameRule.check(state.rules, {:play, player}) do
          state
          |> update_last_cards_and_type(cards, meta)
          |> update_rules(new_rule)
          |> remove_hands(player, cards)
          |> reply_success(new_rule.state)
        else
          :error ->
            {:reply, :error, state}
        end

      _ ->
        with {:ok, new_rule} <- GameRule.check(state.rules, {:play, player}),
             {:ok, meta} <- Card.compare({cards, state.last.card}, state.last.meta) do
          state
          |> update_last_cards_and_type(cards, meta)
          |> update_rules(new_rule)
          |> remove_hands(player, cards)
          |> reply_success(new_rule.state)
        else
          :error ->
            {:reply, :error, state}
        end
    end
  end

  def handle_call({:pass, player}, _from, state) do
    case GameRule.check(state.rules, {:pass, player}) do
      {:ok, rules, :round_over} ->
        state
        |> update_rules(rules)
        |> clear_last()
        |> reply_success(rules.state)

      {:ok, rules} ->
        state
        |> update_rules(rules)
        |> reply_success(rules.state)

      :error ->
        {:reply, :error, state}
    end
  end

  def init(params) do
    {:ok, fresh_state(params)}
  end

  def fresh_state(guid) do
    player1 = %{name: nil, hands: nil, pools: nil}
    player2 = %{name: nil, hands: nil, pools: nil}
    player0 = %{name: nil, hands: nil, pools: nil}
    landlord_cards = %{hands: nil}

    rule = GameRule.new()

    %{
      player0: player0,
      player1: player1,
      player2: player2,
      landlord_cards: landlord_cards,
      last: %{
        card: nil,
        meta: nil
      },
      rules: rule,
      game_id: guid
    }
  end

  def update_rules(state, rules) do
    %{state | rules: rules}
  end

  def reply_success(state, reply), do: {:reply, reply, state}

  def reply_success(state), do: {:reply, state, state}

  def sort_hands(state, player) do
    cards = get_in(state, [player, :hands])
    put_in(state, [player, :hands], Enum.sort_by(cards, fn x -> x.value end))
  end

  def deal_cards(state, rules) do
    [f, s, t, l] =
      Card.new()
      |> Card.shuffle()
      |> Card.deal_cards()

    state
    |> add_hands(:player0, f)
    |> add_hands(:player1, s)
    |> add_hands(:player2, t)
    |> add_hands(:landlord_cards, l)
    |> update_rules(rules)
  end

  def deal_finished(state) do
    with {:ok, rules} <- GameRule.check(Map.fetch!(state, :rules), :deal_finished) do
      state
      |> update_rules(rules)
    else
      :error -> {:reply, :error, state}
    end
  end

  def update_last_cards_and_type(state, cards, meta) do
    last = %{state.last | card: cards, meta: meta}
    %{state | last: last}
  end

  def remove_hands(state, player, cards) do
    new_hands = Enum.filter(get_in(state, [player, :hands]), fn x -> !Enum.member?(cards, x) end)
    put_in(state, [player, :hands], new_hands)
  end

  def add_hands(state, player, cards) do
    if state[player][:hands] == nil do
      put_in(state, [player, :hands], cards)
    else
      put_in(state, [player, :hands], state[player][:hands] ++ cards)
    end
    |> sort_hands(player)
  end

  def clear_last(state) do
    last = %{state.last | card: nil, meta: nil}
    %{state | last: last}
  end
end

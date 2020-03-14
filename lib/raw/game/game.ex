defmodule Raw.Game.Game do
  use GenServer
  alias Raw.Game.{Card, GameRule, CardRuleSelector, CardCompare}

  def start_link(%{guid: guid} = params) do
    GenServer.start_link(__MODULE__, guid, name: via(params.guid))
  end

  def via(name), do: {:via, Registry, {Registry.Game, name}}

  def player_join(game), do: GenServer.call(game, :add_player)

  def player_get_ready(game, player), do: GenServer.call(game, {:get_ready, player})

  def pass_landlord(game, player),
    do: GenServer.call(game, {:pass_landlord, player})

  def accept_landlord(game, player),
    do: GenServer.call(game, {:accept_landlord, player})

  def player_round(game, player, cards), do: GenServer.call(game, {:play, player, cards})

  def pass_round(game, player), do: GenServer.call(game, {:pass, player})

  def handle_call(:add_player, _from, state) do
    with {:ok, player, rules} <- GameRule.check(state.rules, :add_player) do
      new_state =
        state
        |> update_rules(rules)

      {:reply, player, new_state}
    else
      :error -> {:reply, :error, state}
    end
  end

  def handle_call({:get_ready, player}, _from, state) do
    with {:ok, rules} <- GameRule.check(state.rules, {:get_ready, player}) do
      if rules.state == :deal_cards do
        state
        |> deal_cards(rules)
        |> deal_finished()
      else
        state
        |> update_rules(rules)
        |> reply_success(:ok)
      end
    else
      :error -> {:reply, :error, state}
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
      |> reply_success()
    end
  end

  def handle_call({:play, player, cards}, _from, state) do
    case state.last_card do
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
          :error -> {:reply, :error, state}
        end

      last ->
        with {:ok, new_rule} <- GameRule.check(state.rules, {:play, player}),
             {:ok, meta} <- CardCompare.compare(cards, state.last_card_meta, state.last_card) do
          state
          |> update_last_cards_and_type(cards, meta)
          |> update_rules(new_rule)
          |> remove_hands(player, cards)
          |> reply_success(new_rule.state)
        else
          :error -> {:reply, :error, state}
        end
    end
  end

  def handle_call({:pass, player}, _from, state) do
    with {:ok, rules} <- GameRule.check(state.rules, {:pass, player}) do
      state
      |> update_rules(rules)
      |> reply_success(rules.state)
    else
      :error -> {:reply, :error, state}
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
      last_card: nil,
      last_card_meta: nil,
      rules: rule,
      game_id: guid
    }
  end

  def player_key(state) do
    key = 3 - length(Map.fetch!(state, :absent))
    String.to_existing_atom("player" <> to_string(key))
  end

  def update_rules(state, rules) do
    %{state | rules: rules}
  end

  def reply_success(state, reply), do: {:reply, reply, state}

  def reply_success(state), do: {:reply, state, state}

  def update_hands(state, player, cards),
    do: put_in(state, [player, :hands], Enum.sort_by(cards, fn x -> x.value end))

  def deal_cards(state, rules) do
    [f, s, t, l] =
      Card.new()
      |> Card.shuffle()
      |> Card.deal_cards()

    state
    |> update_hands(:player0, f)
    |> update_hands(:player1, s)
    |> update_hands(:player2, t)
    |> update_hands(:landlord_cards, l)
    |> update_rules(rules)
  end

  def deal_finished(state) do
    with {:ok, rules} <- GameRule.check(Map.fetch!(state, :rules), :deal_finished) do
      state
      |> update_rules(rules)
      |> reply_success()
    else
      :error -> {:reply, :error, state}
    end
  end

  def update_last_cards_and_type(state, cards, meta) do
    new_state = put_in(state.last_card, cards)
    put_in(new_state.last_card_meta, meta)
  end

  def remove_hands(state, player, cards) do
    new_hands = Enum.filter(get_in(state, [player, :hands]), fn x -> !Enum.member?(cards, x) end)
    put_in(state, [player, :hands], new_hands)
  end
end

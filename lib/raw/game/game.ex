defmodule Raw.Game.Game do
  use GenServer
  alias Raw.Game.{Card, GameRule}

  def start_link(%{guid: guid} = params) do
    GenServer.start_link(__MODULE__, guid, name: via(params.guid))
  end

  def via(name), do: {:via, Registry, {Registry.Game, name}}

  def player_join(game, _name), do: GenServer.call(game, :add_player)

  def player_get_ready(game, player), do: GenServer.call(game, {:get_ready, player})

  def landlord(game, player), do: GenServer.call(game, {:landlord_selected, player})

  def handle_call(:add_player, _from, state) do
    with {:ok, key, new_state} <- choose_absent(state),
         {:ok, rules} <- GameRule.check(new_state.rules, {:add_player, key}) do
      s =
        new_state
        |> update_rules(rules)

      {:reply, player_key(s), s}
    else
      :error -> {:reply, :error, state}
    end
  end

  def handle_call({:get_ready, player}, _from, state) do
    with {:ok, rules} <- GameRule.check(state.rules, {:get_ready, player}) do
      if rules.state == :deal_cards do
        new_state =
          state
          |> update_rules(rules)
          |> deal_cards()

        with {:ok, r} <- GameRule.check(Map.fetch!(new_state, :rules), :deal_finished) do
          new_state
          |> update_rules(r)
          |> reply_success(new_state)
        else
          :error -> {:reply, :error, new_state}
        end
      else
        state
        |> update_rules(rules)
        |> reply_success(:ok)
      end
    else
      :error -> {:reply, :error, state}
    end
  end

  def handle_call({:landlord_selected, player}, _from, state) do
    with {:ok, rules} <- GameRule.check(state.rules, {:landlord_selected, player}) do
      state
      |> update_landlord(player)
      |> update_rules(rules)
      |> reply_success(state)
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
    player3 = %{name: nil, hands: nil, pools: nil}
    landlord = %{hands: nil, player: nil}

    rule = GameRule.new()

    %{
      player1: player1,
      player2: player2,
      player3: player3,
      landlord: landlord,
      rules: rule,
      absent: [:player1, :player2, :player3],
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

  def reply_success(new_state, reply), do: {:reply, reply, new_state}

  def choose_absent(state) do
    if length(state.absent) == 0 do
      :error
    else
      {:ok, hd(state.absent), %{state | absent: tl(state.absent)}}
    end
  end

  def update_hands(state, player, cards), do: put_in(state, [player, :hands], Enum.sort_by(cards, fn x -> x.value end))

  def update_landlord(state, player) do
    put_in(state.landlord.player, player)
  end

  def deal_cards(state) do
    [f, s, t, l] =
      Card.new()
      |> Card.shuffle()
      |> Card.deal_cards()

    state
    |> update_hands(:player1, f)
    |> update_hands(:player2, s)
    |> update_hands(:player3, t)
    |> update_hands(:landlord, l)
  end
end

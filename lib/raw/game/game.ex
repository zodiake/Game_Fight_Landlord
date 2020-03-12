defmodule Raw.Game.Game do
  use GenServer
  @module __MODULE__
  alias Raw.Game.{Card, GameRule}

  def start_link(%{guid: guid} = params) do
    GenServer.start_link(@module, guid, name: via(guid))
  end

  def via(name), do: {:via, Registry, {Registry.Game, name}}

  def player_join(game, name), do: GenServer.call(game, :add_player)

  def handle_call(:add_player, _from, state) do
    with {:ok, rules} <- GameRule.check(state.rules, :add_player) do
      state
      |> update_rules(rules)
      |> reply_success(player_key(rules))
    else
      :error -> {:reply, :error, state}
    end
  end

  def handle_call({:get_ready, name}, _from, state) do
  end

  def init(params) do
    {:ok, fresh_state(params)}
  end

  def fresh_state(params) do
    player1 = %{name: nil, hands: nil, pools: nil}
    player2 = %{name: nil, hands: nil, pools: nil}
    player3 = %{name: nil, hands: nil, pools: nil}

    rule = GameRule.new()

    %{
      player1: player1,
      player2: player2,
      player3: player3,
      rules: rule,
      game_id: params.guid
    }
  end

  def player_key(rules) do
    key = 3 - length(rules.absent)
    String.to_existing_atom("player" <> to_string(key))
  end

  def update_rules(state, rules) do
    %{state | rules: rules}
  end

  def reply_success(new_state, reply) do
    {:reply, reply, new_state}
  end
end

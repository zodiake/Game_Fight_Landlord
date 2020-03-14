defmodule Raw.Game.GameTest do
  alias __MODULE__
  use ExUnit.Case
  alias Raw.Game.{Game, GameRule}

  test "game should empty when init" do
    Game.start_link(%{guid: 1})
    state = :sys.get_state(Game.via(1))
    assert state.game_id == 1
    assert state.rules.state == :waiting_start
  end

  test "after player join game should set player" do
    Game.start_link(%{guid: 1})
    Game.player_join(Game.via(1))
    Game.player_join(Game.via(1))
    Game.player_join(Game.via(1))
    assert Game.player_join(Game.via(1)) == :error
    state = :sys.get_state(Game.via(1))
    assert state.rules.player0 == :joined_room

    assert Game.player_get_ready(Game.via(1), :player0) == :ok
    assert Game.player_get_ready(Game.via(1), :player1) == :ok
    state = Game.player_get_ready(Game.via(1), :player2)
    assert state.rules.player0 == :get_ready
    assert state.rules.player1 == :get_ready
    assert state.rules.player2 == :get_ready
    assert state.rules.state == :landlord_electing

    next_player = Game.pass_landlord(Game.via(1), state.rules.source_landlord)

    s = Game.accept_landlord(Game.via(1), next_player)
    assert s.rules.state == String.to_atom(to_string(next_player) <> "_turn")

    out = [hd(get_in(s, [next_player, :hands]))]
    nn_player = GameRule.next_player(next_player)
    q = Game.player_round(Game.via(1), next_player, out)
    assert q == String.to_atom(to_string(nn_player) <> "_turn")

  end
end

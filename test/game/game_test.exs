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

    player0 = Game.pass_landlord(Game.via(1), state.rules.source_landlord)

    s = Game.accept_landlord(Game.via(1), player0)
    assert s.rules.state == String.to_atom(to_string(player0) <> "_turn")

    first = [hd(s[player0][:hands])]
    player1_turn = Game.player_round(Game.via(1), player0, first)
    state = :sys.get_state(Game.via(1))
    assert player1_turn == next_turn(player0)
    assert length(state.rules.round_cards) == 1

    player2_turn = Game.pass_round(Game.via(1), turn_to_player(player1_turn))
    assert player2_turn == next_turn(turn_to_player(player1_turn))
  end

  def next_turn(player) do
    String.to_atom(to_string(GameRule.next_player(player)) <> "_turn")
  end

  def turn_to_player(turn) do
    String.to_atom(hd(String.split(to_string(turn), "_")))
  end
end

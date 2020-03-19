defmodule Raw.Game.GameTest do
  alias __MODULE__
  use ExUnit.Case
  alias Raw.Game.{GameEngine, GameRule}

  test "game should empty when init" do
    GameEngine.start_link(1)
    state = :sys.get_state(GameEngine.via(1))
    assert state.game_id == 1
    assert state.rules.state == :waiting_start
  end

  test "test landlord play card two passed and should landlord play" do
    GameEngine.start_link(1)
    GameEngine.player_join(GameEngine.via(1))
    GameEngine.player_join(GameEngine.via(1))
    GameEngine.player_join(GameEngine.via(1))
    assert GameEngine.player_join(GameEngine.via(1)) == :error
    state = :sys.get_state(GameEngine.via(1))
    assert state.rules.player0 == :joined_room

    assert GameEngine.player_get_ready(GameEngine.via(1), :player0) == :ok
    assert GameEngine.player_get_ready(GameEngine.via(1), :player1) == :ok
    state = GameEngine.player_get_ready(GameEngine.via(1), :player2)
    assert state.rules.player0 == :get_ready
    assert state.rules.player1 == :get_ready
    assert state.rules.player2 == :get_ready
    assert state.rules.state == :landlord_electing

    player0 = GameEngine.pass_landlord(GameEngine.via(1), state.rules.source_landlord)

    s = GameEngine.accept_landlord(GameEngine.via(1), player0)
    assert s.rules.state == String.to_atom(to_string(player0) <> "_turn")
    assert length(get_in(s,[player0,:hands])) == 20

    # first play all pass
    first = [hd(s[player0][:hands])]
    player1_turn = GameEngine.play_round(GameEngine.via(1), player0, first)
    player1 = turn_to_player(player1_turn)
    state = :sys.get_state(GameEngine.via(1))
    assert player1_turn == next_turn(player0)
    assert length(state.rules.round_cards) == 1

    player2_turn = GameEngine.pass_round(GameEngine.via(1), turn_to_player(player1_turn))
    player2 = turn_to_player(player2_turn)

    player0_turn = GameEngine.pass_round(GameEngine.via(1), turn_to_player(player2_turn))
    state = :sys.get_state(GameEngine.via(1))
    assert state.rules.round_cards == []
    assert state.last.card == nil
    assert state.last.meta == nil
    assert length(state[player0][:hands]) == 19
    assert length(state[player1][:hands]) == 17
    assert length(state[player2][:hands]) == 17
    assert state.rules.state == player0_turn

    # first play0:play->player1:play->player2:pass->player0:pass->player1_turn
    state = :sys.get_state(GameEngine.via(1))
    first = [hd(state[player0][:hands])]
    GameEngine.play_round(GameEngine.via(1), player0, first)
    first1_all = state[player1][:hands]
    state = :sys.get_state(GameEngine.via(1))
    assert state.last.meta == :single
    first1 = Enum.find(first1_all, fn x -> x.value > hd(first).value end)
    GameEngine.play_round(GameEngine.via(1), player1, [first1])
    GameEngine.pass_round(GameEngine.via(1), player2)
    GameEngine.pass_round(GameEngine.via(1), player0)

    state = :sys.get_state(GameEngine.via(1))
    assert state.rules.round_cards == []
    assert length(state[player0][:hands]) == 18
    assert length(state[player1][:hands]) == 16
    assert length(state[player2][:hands]) == 17

  end

  def next_turn(player) do
    String.to_atom(to_string(GameRule.next_player(player)) <> "_turn")
  end

  def turn_to_player(turn) do
    String.to_atom(hd(String.split(to_string(turn), "_")))
  end
end

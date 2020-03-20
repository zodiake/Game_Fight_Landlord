defmodule Raw.Game.GameTest do
  alias __MODULE__
  use ExUnit.Case
  alias Raw.Game.{GameEngine, GameRule}

  test "game should empty when init" do
    GameEngine.start_link(1)
    state = :sys.get_state(GameEngine.via(1))
    assert state.id == 1
    assert state.rule.rule_state == :waiting_start
  end

  test "test landlord play card two passed and should landlord play" do
    [p1, p2, p3] = all_joined_room(1)
    pid = GameEngine.via(1)
    player3 = GameEngine.player_join(pid)
    assert player3 == :error
  end

  test "test can not get_ready twice" do
    [p1, p2, p3] = all_joined_room(1)
    pid = GameEngine.via(1)
    assert GameEngine.player_get_ready(pid, p1) == :ok
    assert GameEngine.player_get_ready(pid, p1) == :error
  end

  test "when all ready" do
    [p1, p2, p3] = all_joined_room(1)
    pid = GameEngine.via(1)
    assert GameEngine.player_get_ready(pid, p1) == :ok
    assert GameEngine.player_get_ready(pid, p2) == :ok

    [player0: h1, player1: h2, player2: h3, landlord: h4, extra_cards: h5] =
      GameEngine.player_get_ready(pid, p3)

    assert length(h1) == 17
    assert length(h2) == 17
    assert length(h3) == 17
    assert length(h5) == 3
  end

  test "accept landlord" do
    [p1, p2, p3] = all_joined_room(1)
    pid = GameEngine.via(1)
    assert GameEngine.player_get_ready(pid, p1) == :ok
    assert GameEngine.player_get_ready(pid, p2) == :ok

    [player0: h1, player1: h2, player2: h3, landlord: h4, extra_cards: h5] =
      GameEngine.player_get_ready(pid, p3)

    assert GameEngine.accept_landlord(pid, h4) ==
             String.to_existing_atom(to_string(h4) <> "_turn")
  end

  test "pass landlord" do
    [p1, p2, p3] = all_joined_room(1)
    pid = GameEngine.via(1)
    assert GameEngine.player_get_ready(pid, p1) == :ok
    assert GameEngine.player_get_ready(pid, p2) == :ok

    [player0: h1, player1: h2, player2: h3, landlord: h4, extra_cards: h5] =
      GameEngine.player_get_ready(pid, p3)

    np = GameEngine.pass_landlord(pid, h4)
    assert np != :error

    assert GameEngine.accept_landlord(pid, np) ==
             String.to_existing_atom(to_string(GameRule.next_player(h4)) <> "_turn")
  end

  defp all_joined_room(id) do
    GameEngine.start_link(id)
    pid = GameEngine.via(id)
    player1 = GameEngine.player_join(pid)
    player2 = GameEngine.player_join(pid)
    player3 = GameEngine.player_join(pid)
    [player1, player2, player3]
  end

  def next_turn(player) do
    String.to_atom(to_string(GameRule.next_player(player)) <> "_turn")
  end

  def turn_to_player(turn) do
    String.to_atom(hd(String.split(to_string(turn), "_")))
  end
end

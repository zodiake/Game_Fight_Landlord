defmodule Raw.Game.GameTest do
  alias __MODULE__
  use ExUnit.Case
  alias Raw.Game.Game

  test "game should empty when init" do
    game = Game.start_link(%{guid: 1})
    state = :sys.get_state(game)
    assert state.game_id == 1
  end
end

defmodule Raw.Game.GameTest do
  alias __MODULE__
  use ExUnit.Case
  alias Raw.Game.Game

  test "should success" do
    {:ok, game} = Game.start_link(%{guid: 1})

    p1 =
      game
      |> Game.player_join("tom")

    p2 =
      game
      |> Game.player_join("mary")

    p3 =
      game
      |> Game.player_join("mary")

    game
    |> Game.player_get_ready(p1)
    game
    |> Game.player_get_ready(p2)
    %{rules: rule} = game
                     |> Game.player_get_ready(p3)
                     |> IO.inspect()


    assert p1 == :player1
    assert p2 == :player2
    assert p3 == :player3
    assert rule.state == :deal_cards
  end
end

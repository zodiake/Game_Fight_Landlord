defmodule Raw.Game.GameRuleTest do
  alias __MODULE__
  use ExUnit.Case
  alias Raw.Game.GameRule

  def after_join() do
    rule = GameRule.new()

    with {:ok, rules1} <- GameRule.check(rule, {:add_player, :player1}),
         {:ok, rules2} <- GameRule.check(rules1, {:add_player, :player2}),
         {:ok, rules3} <- GameRule.check(rules2, {:add_player, :player3}) do
      rules3
    else
      :error -> IO.inspect(:error)
    end
  end

  test "game rule should deal cards when all join" do
    rules = GameRuleTest.after_join()

    assert rules.state == :game_start
  end

  test "game state should be landlord_player1 after deal finished" do
    rules = GameRuleTest.after_join()

    {:ok, rule} =
      rules
      |> GameRule.check({:deal_finished, :player1})

    assert rule.state == :landlord_player1
  end

  test "after landlord_finished player2 game should be player2_turn" do
    rules = GameRuleTest.after_join()

    {:ok, rules} =
      rules
      |> GameRule.check({:deal_finished, :player1})

    {:ok, rules} = GameRule.check(rules, {:landload_finished, :player2})

    assert rules.state == :player2_turn
  end
end

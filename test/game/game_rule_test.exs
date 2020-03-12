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

    assert rules.state == :waiting_start

    assert GameRule.check(rules, :add_player) == :error
  end

  test "game should start after all player get_ready" do
    rules = GameRuleTest.after_join()
    rules = rules
            |> GameRule.check({:get_ready, :player1})
            |> elem(1)
            |> GameRule.check({:get_ready, :player2})
            |> elem(1)
            |> GameRule.check({:get_ready, :player3})
    assert elem(rules, 1).state == :deal_cards
  end

end

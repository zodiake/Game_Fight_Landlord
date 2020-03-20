defmodule Raw.Game.GameRuleTest do
  alias __MODULE__
  use ExUnit.Case
  alias Raw.Game.GameRule

  def after_join() do
    rule = GameRule.new()

    with {:ok, _, rules1} <- GameRule.check(rule, :add_player),
         {:ok, _, rules2} <- GameRule.check(rules1, :add_player),
         {:ok, _, rules3} <- GameRule.check(rules2, :add_player) do
      rules3
    else
      :error -> :error
    end
  end

  test "game rule should deal cards when all join" do
    rules = GameRuleTest.after_join()

    assert rules.rule_state == :waiting_start

    assert rules.player0 == :joined_room
    assert rules.player2 == :joined_room
    assert rules.player1 == :joined_room
  end

  test "game should start after all player get_ready" do
    rules = GameRuleTest.after_join()

    rules =
      rules
      |> GameRule.check({:get_ready, :player0})
      |> elem(1)
      |> GameRule.check({:get_ready, :player1})
      |> elem(1)
      |> GameRule.check({:get_ready, :player2})
      |> elem(1)

    assert rules.rule_state == :landlord_electing
    assert rules.source_landlord != nil
    assert rules.landlord == nil

    {:ok, _, nr} =
      rules
      |> GameRule.check({:pass_landlord, rules.source_landlord})

    assert nr.give_up == [rules.source_landlord]
    assert nr.rule_state == :landlord_electing
    landlord = GameRule.next_player(rules.source_landlord)
    {:ok, nnr} = nr
                 |> GameRule.check({:accept_landlord, landlord})
    assert nnr.rule_state == String.to_atom(to_string(landlord) <> "_turn")
  end
end

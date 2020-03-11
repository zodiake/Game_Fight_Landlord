defmodule Raw.Game.GameRule do
  alias __MODULE__
  @moduledoc false
  @max_entered 3
  defstruct state: :waiting_players,
            player1: :not_set,
            player2: :not_set,
            player3: :not_set

  def new(), do: %GameRule{}

  def check(%GameRule{state: :waiting_players} = game_rule, {:add_player, player}) do
    case Map.fetch!(game_rule, player) do
      :not_set ->
        rules =
          game_rule
          |> Map.put(player, :get_ready)
          |> Map.put(:state, :waiting_players)

        if all_players_get_ready(rules) do
          {:ok, %GameRule{rules | state: :game_start}}
        else
          {:ok, rules}
        end

      :get_ready ->
        :error
    end
  end

  def check(%GameRule{state: :game_start} = game_rule, {:deal_finished, landlord_player}) do
    case landlord_player do
      :player1 -> {:ok, %GameRule{game_rule | state: :landlord_player1}}
      :player2 -> {:ok, %GameRule{game_rule | state: :landlord_player2}}
      :player3 -> {:ok, %GameRule{game_rule | state: :landlord_player3}}
    end
  end

  def check(%GameRule{state: :landlord_player1} = game_rule, {:landload_finished, player}) do
    case player do
      :player1 -> {:ok, %GameRule{game_rule | state: :player1_turn}}
      :player2 -> {:ok, %GameRule{game_rule | state: :player2_turn}}
      :player3 -> {:ok, %GameRule{game_rule | state: :player3_turn}}
    end
  end

  def check(%GameRule{state: :landlord_player2} = game_rule, {:landload_finished, player}) do
    case player do
      :player1 -> {:ok, %GameRule{game_rule | state: :player1_turn}}
      :player2 -> {:ok, %GameRule{game_rule | state: :player2_turn}}
      :player3 -> {:ok, %GameRule{game_rule | state: :player3_turn}}
    end
  end

  def check(%GameRule{state: :landlord_player3} = game_rule, {:landload_finished, player}) do
    case player do
      :player1 -> {:ok, %GameRule{game_rule | state: :player1_turn}}
      :player2 -> {:ok, %GameRule{game_rule | state: :player2_turn}}
      :player3 -> {:ok, %GameRule{game_rule | state: :player3_turn}}
    end
  end

  def check(%GameRule{state: :player1_turn} = game_rule, {:play, :player1}) do
    {:ok, %GameRule{game_rule | state: :play2_turn}}
  end
  def check(%GameRule{state: :player2_turn} = game_rule, {:play, :player2}) do
    {:ok, %GameRule{game_rule | state: :play3_turn}}
  end
  def check(%GameRule{state: :player3_turn} = game_rule, {:play, :player3}) do
    {:ok, %GameRule{game_rule | state: :play1_turn}}
  end

  def check(%GameRule{state: :player3_turn} = game_rule, {:win_check, win_or_not}) do
    case win_or_not do
      :win -> %GameRule{game_rule | state: :game_over}
      :not_win -> {:ok, game_rule}
    end
  end

  def check(%GameRule{state: :player1_turn} = game_rule, {:win_check, win_or_not}) do
    case win_or_not do
      :win -> %GameRule{game_rule | state: :game_over}
      :not_win -> {:ok, game_rule}
    end
  end

  def check(%GameRule{state: :player2_turn} = game_rule, {:win_check, win_or_not}) do
    case win_or_not do
      :win -> %GameRule{game_rule | state: :game_over}
      :not_win -> {:ok, game_rule}
    end
  end

  def check(_rule, _state), do: :error

  def all_players_get_ready(rules) do
    rules.player1 == :get_ready && rules.player2 == :get_ready && rules.player3 == :get_ready
  end

end

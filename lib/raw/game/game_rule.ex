defmodule Raw.Game.GameRule do
  alias __MODULE__
  alias Raw.Game.Round
  @moduledoc false
  @max_entered 3
  defstruct rule_state: :waiting_start,
            round: %Round{},
            absent: 3,
            player0: :not_set,
            player1: :not_set,
            player2: :not_set,
            extra_cards: [],
            landlord: nil,
            give_up: 0

  def new(), do: %GameRule{}

  def check(%GameRule{rule_state: :waiting_start} = game_rule, :add_player) do
    absent = game_rule.absent

    if absent > 0 do
      player = String.to_atom("player" <> to_string(rem(absent, 3)))

      game_rule
      |> update_player_state(player, :joined_room)
      |> update_absent(&(&1 - 1))
      |> reply_success(player)
    else
      :error
    end
  end

  def check(%GameRule{rule_state: :waiting_start} = game_rule, {:get_ready, player}) do
    case Map.fetch!(game_rule, player) do
      :joined_room ->
        rule =
          game_rule
          |> update_player_state(player, :get_ready)

        if all_players_get_ready(rule) do
          rule
          |> update_player_state(player, :get_ready)
          |> update_landlord(random_landlord())
          |> update_state(:landlord_electing)
          |> reply_success
        else
          rule
          |> reply_success
        end

      :get_ready ->
        :error
    end
  end

  def check(%GameRule{rule_state: :landlord_electing} = game_rule, {:pass_landlord, player}) do
    rule = game_rule |> add_give_up

    if rule.give_up == 3 do
      {:restart, %GameRule{}}
    else
      rule |> update_landlord(next_player(player)) |> reply_success
    end
  end

  def check(%GameRule{rule_state: :landlord_electing} = game_rule, {:accept_landlord, player}) do
    if game_rule.landlord == player do
      game_rule
      |> update_state(:game_start)
      |> update_round(player)
      |> reply_success
    else
      :error
    end
  end

  def check(%GameRule{rule_state: turn} = game_rule, {:play, player}) do
  end

  def check(%GameRule{rule_state: player_turn} = game_rule, {:pass, player}) do
  end

  def check(%GameRule{rule_state: :player0_turn} = game_rule, {:win_check, win_or_not}) do
    case win_or_not do
      :win -> %GameRule{game_rule | rule_state: :game_over}
      :not_win -> {:ok, game_rule}
    end
  end

  def check(%GameRule{rule_state: :player1_turn} = game_rule, {:win_check, win_or_not}) do
    case win_or_not do
      :win -> %GameRule{game_rule | rule_state: :game_over}
      :not_win -> {:ok, game_rule}
    end
  end

  def check(%GameRule{rule_state: :player2_turn} = game_rule, {:win_check, win_or_not}) do
    case win_or_not do
      :win -> %GameRule{game_rule | rule_state: :game_over}
      :not_win -> {:ok, game_rule}
    end
  end

  def check(_rule, _state), do: :error

  def all_players_get_ready(rules) do
    rules.player1 == :get_ready && rules.player2 == :get_ready && rules.player0 == :get_ready
  end

  def random_landlord(), do: Enum.random([:player0, :player1, :player2])

  def add_give_up(rule) do
    %GameRule{rule | give_up: rule.give_up + 1}
  end

  def update_state(rule, state), do: %GameRule{rule | rule_state: state}

  def player_can_participate_electing(rule, player) do
    case rule.landlord do
      nil ->
        not Enum.member?(rule.give_up, player)

      _ ->
        false
    end
  end

  def update_round(rule, player) do
    turn = String.to_existing_atom(to_string(player) <> "_turn")
    round = %Round{rule.round | turn: turn}
    %GameRule{rule | round: round}
  end

  def update_landlord(rule, player), do: %__MODULE__{rule | landlord: player}

  def reply_success(rule), do: {:ok, rule}

  def reply_success(rule, res), do: {:ok, res, rule}

  def next_player(player) do
    case player do
      :player0 -> :player1
      :player1 -> :player2
      :player2 -> :player0
    end
  end

  defp update_player_state(rule, player, state) do
    Map.put(rule, player, state)
  end

  defp update_absent(rule, fun) do
    %__MODULE__{rule | absent: fun.(rule.absent)}
  end
end

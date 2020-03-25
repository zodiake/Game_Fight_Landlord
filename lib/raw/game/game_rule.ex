defmodule Raw.Game.GameRule do
  alias __MODULE__
  alias Raw.Game.Round
  @moduledoc false
  @max_entered 3
  defstruct rule_state: :waiting_start,
            round: %Round{},
            players: [
              player0: :not_set,
              player1: :not_set,
              player2: :not_set
            ],
            landlord: nil,
            give_up: []

  def new(), do: %GameRule{}

  def check(%GameRule{rule_state: :waiting_start} = rule, :add_player) do
    case rule.players
         |> find_absent do
      [] ->
        :error

      [h | t] ->
        key =
          h
          |> elem(0)

        players =
          rule.players
          |> update_player(key, :joined_room)

        {:ok, key, update_players(rule, players)}
    end
  end

  def check(%GameRule{rule_state: :waiting_start} = rule, {:get_ready, player}) do
    case Keyword.get(rule.players, player) do
      :joined_room ->
        players = update_player(rule.players, player, :get_ready)

        if all_players_get_ready(players) do
          rule =
            rule
            |> update_players(players)
            |> update_landlord(random_landlord)
            |> update_state(:landlord_electing)

          {:ok, rule}
        else
          rule =
            rule
            |> update_players(players)

          {:ok, rule}
        end

      _ ->
        :error
    end
  end

  def check(%GameRule{rule_state: :landlord_electing} = rule, {:pass_landlord, player}) do
    case Enum.member?(rule.give_up, player) do
      true ->
        :error

      false ->
        rule =
          rule
          |> add_give_up(player)

        if length(rule.give_up) == 3 do
          {:restart, %GameRule{}}
        else
          next_player = next_player(player)

          {
            :ok,
            rule
            |> update_landlord(next_player)
          }
        end
    end
  end

  def check(%GameRule{rule_state: :landlord_electing} = game_rule, {:accept_landlord, player}) do
    if game_rule.landlord == player do
      game_rule
      |> update_state(:game_start)
      |> update_round(&Round.update_first_hand(&1, player))
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

  def all_players_get_ready(players) do
    players
    |> Keyword.values()
    |> Enum.all?(&(&1 == :get_ready))
  end

  def random_landlord(), do: Enum.random([:player0, :player1, :player2])

  def add_give_up(rule, player) do
    %GameRule{rule | give_up: [player | rule.give_up]}
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

  def update_round(rule, fun) do
    %GameRule{rule | round: fun.(rule.round)}
  end

  def update_landlord(rule, player) do
    %__MODULE__{rule | landlord: player}
  end

  def reply_success(rule), do: {:ok, rule}

  def reply_success(rule, res), do: {:ok, res, rule}

  def next_player(player) do
    case player do
      :player0 -> :player1
      :player1 -> :player2
      :player2 -> :player0
    end
  end

  defp find_absent(players) do
    players
    |> Enum.filter(fn {_k, v} -> v == :not_set end)
  end

  defp update_player_state(rule, player, state) do
    Map.put(rule, player, state)
  end

  defp update_players(rule, players) do
    %GameRule{rule | players: players}
  end

  defp update_player(players, player, state) do
    Keyword.update!(players, player, fn _ -> state end)
  end
end

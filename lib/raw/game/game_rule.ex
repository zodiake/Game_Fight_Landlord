defmodule Raw.Game.GameRule do
  alias __MODULE__
  @moduledoc false
  @max_entered 3
  defstruct state: :waiting_start,
            absent: 3,
            player0: :not_set,
            player1: :not_set,
            player2: :not_set,
            source_landlord: nil,
            round_cards: [],
            give_up: [],
            landlord: nil

  def new(), do: %GameRule{}

  def check(%GameRule{state: :waiting_start} = game_rule, :add_player) do
    absent = game_rule.absent

    if absent > 0 do
      player = String.to_atom("player" <> to_string(rem(absent, 3)))

      rules =
        game_rule
        |> Map.put(player, :joined_room)
        |> Map.put(:absent, absent - 1)

      {:ok, player, rules}
    else
      :error
    end
  end

  def check(%GameRule{state: :waiting_start} = game_rule, {:get_ready, player}) do
    case Map.fetch!(game_rule, player) do
      :joined_room ->
        rules =
          game_rule
          |> Map.put(player, :get_ready)

        if all_players_get_ready(rules) do
          {:ok, update_state(rules, :deal_cards)}
        else
          {:ok, rules}
        end

      :get_ready ->
        :error
    end
  end

  def check(%GameRule{state: :deal_cards} = game_rule, :deal_finished) do
    {:ok, %{game_rule | state: :landlord_electing, source_landlord: random_landlord()}}
  end

  def check(%GameRule{state: :landlord_electing} = game_rule, {:pass_landlord, player}) do
    if player_can_participate_electing(player, game_rule) do
      new_rule =
        game_rule
        |> update_give_up(player)

      {:ok, next_player(player), new_rule}
    else
      :error
    end
  end

  def check(%GameRule{state: :landlord_electing} = game_rule, {:accept_landlord, player}) do
    if player_can_participate_electing(player, game_rule) do
      new_rule =
        game_rule
        |> update_turn(player)

      {:ok, %GameRule{new_rule | landlord: player}}
    else
      :error
    end
  end

  def check(%GameRule{state: turn} = game_rule, {:play, player}) do
    if turn != String.to_atom(to_string(player) <> "_turn") do
      :error
    else
      {
        :ok,
        game_rule
        |> add_round(%{player: player, play_or_pass: :play})
        |> update_turn(next_player(player))
      }
    end
  end

  def check(%GameRule{state: player_turn} = game_rule, {:pass, player}) do
    if game_rule.round_cards == [] do
      :error
    else
      update_round_cards(game_rule, game_rule.round_cards, :pass, player)
    end
  end

  def check(%GameRule{state: :player0_turn} = game_rule, {:win_check, win_or_not}) do
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
    rules.player1 == :get_ready && rules.player2 == :get_ready && rules.player0 == :get_ready
  end

  def all_players_joined(rules) do
    rules.player1 == :joined_room && rules.player2 == :joined_room &&
      rules.player0 == :joined_room
  end

  def random_landlord(), do: Enum.random([:player0, :player1, :player2])

  def update_give_up(rule, player) do
    if rule.give_up == [] do
      %GameRule{rule | give_up: [player]}
    else
      %GameRule{rule | give_up: [player | rule.give_up]}
    end
  end

  def update_state(rule, state), do: %GameRule{rule | state: state}

  def update_round_cards(rule, round_cards, passed_or_played, player)
      when passed_or_played in [:passed, :played]
           when length(round_cards) == 1 do
    new_rule =
      rule
      |> add_round(%{player: player, play_or_pass: passed_or_played})
      |> update_turn(next_player(player))

    {:ok, new_rule}
  end

  def update_round_cards(rule, round_cards, passed_or_played, player)
      when passed_or_played in [:passed, :played]
           when length(round_cards) >= 2 do
    last = hd(round_cards)

    if last.type == :passed do
      next_player =
        Enum.filter([:player0, :player1, :player2], &(&1 != last.player and &1 != player))

      new_rule =
        rule
        |> update_turn(next_player)
        |> clear_round()

      {:ok, new_rule}
    else
      new_rule =
        rule
        |> add_round(%{player: player, play_or_pass: passed_or_played})

      {:ok, new_rule}
    end
  end

  def player_can_participate_electing(player, rule) do
    case rule.landlord do
      nil ->
        containers = Enum.member?(rule.give_up, player)

        if containers == false do
          true
        else
          false
        end

      _ ->
        false
    end
  end

  def update_turn(rule, player) when is_binary(player) do
    state = String.to_atom(player <> "_turn")
    update_state(rule, state)
  end

  def update_turn(rule, player) when is_atom(player) do
    state = String.to_atom(to_string(player) <> "_turn")
    update_state(rule, state)
  end

  def clear_round(rule), do: %GameRule{rule | round_cards: []}

  def add_round(rule, %{player: player, play_or_pass: type} = round) do
    %GameRule{rule | round_cards: [round | rule.round_cards]}
  end

  def next_player(player) do
    case player do
      :player0 -> :player1
      :player1 -> :player2
      :player2 -> :player0
    end
  end
end

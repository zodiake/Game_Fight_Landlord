defmodule RawWeb.GameChannel do
  use Phoenix.Channel
  alias Raw.Game.{GameEngine, GameSupervisor}
  require Logger

  def join("room:" <> id, _message, socket) do
    pid = GameEngine.via(id)

    case GameEngine.player_join(pid) do
      {:ok, pl} ->
        {
          :ok,
          socket
          |> assign(:player, pl)
          |> assign(:game, id)
        }

      :error ->
        {:error, %{reason: ""}}
    end
  end

  def handle_in("get_ready", _, socket) do
    pid = GameEngine.via(socket.assigns.game)
    case GameEngine.player_get_ready(pid, socket.assigns.player) do
      :ok ->
        push(socket, "ready", %{status: "ok"})
        {:noreply, socket}
      [player0: h1, player1: h2, player2: h3, landlord: ll, extra_cards: h4] ->
        broadcast!(socket, "selecting_landlord", %{extra_cards: h4})
        {:noreply, socket}
    end
  end
end

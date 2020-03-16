defmodule RawWeb.GameChannel do
  use Phoenix.Channel
  alias Raw.Game.{Game, GameSupervisor}

  def join("game:1", _message, socket) do
    {:ok, socket}
  end
end
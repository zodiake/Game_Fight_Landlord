defmodule RawWeb.GameController do
  use RawWeb, :controller
  alias Raw.Game.GameSupervisor
  require Logger

  def create(conn, %{"id" => id} = params) do
    with {:ok, pid} <- GameSupervisor.start_game(id) do
      Logger.debug("pid is: #{inspect pid}")
      conn
      |> json("ok")
    else
      _ ->
        conn
        |> json("fail")
    end
  end
end

defmodule RawWeb.GameController do
  use RawWeb, :controller
  alias Raw.Game.GameSupervisor
  require Logger

  def index(conn, _params) do
    conn
    |> render("index.html")
  end

  def create(conn, %{"id" => id} = params) do
    IO.inspect(params)

    with {:ok, pid} <- GameSupervisor.start_game(id) do
      Logger.debug("pid is: #{inspect(pid)}")

      conn
      |> json("ok")
    else
      _ ->
        conn
        |> json("fail")
    end
  end
end

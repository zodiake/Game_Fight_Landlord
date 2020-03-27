defmodule RawWeb.GameController do
  use RawWeb, :controller
  alias Raw.Game.{GameSupervisor, GameEngine}
  require Logger

  def index(conn, _params) do
    conn
    |> render("index.html")
  end

  def show(conn,_params) do
    conn
    |> render("show.html")
  end

  def create(conn, %{"id" => id} = params) do
    if GameSupervisor.pid_from_guid(id) == nil do
      case GameSupervisor.start_game(id) do
        {:ok, pid} ->
          conn
          |> json("ok")
        {:error, _} ->
          conn
          |> put_status(403)
          |> json("error")
      end
    else
      conn
      |> put_status(403)
      |> json("error")
    end
  end
end

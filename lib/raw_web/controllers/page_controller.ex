defmodule RawWeb.PageController do
  use RawWeb, :controller
  require Logger
  @users ~w[tom,mary,peter]

  def index(conn, _params) do
    if current_path(conn) == "/" do
      if Map.has_key?(conn.assigns, :messages) do
        conn
        |> render("index.html")
      else
        conn
        |> assign(:messages, "ccccc")
        |> render("index.html")
      end
    else
      token = get_session(conn, :token)

      case Phoenix.Token.verify(RawWeb.Endpoint, "salt", token) do
        {:ok, id} when id in @users ->
          conn

        _ ->
          Logger.debug("#redirect")
          conn
          |> redirect(to: "/")
          |> put_flash(:messages, "no login")
          |> halt()
      end
    end
  end
end

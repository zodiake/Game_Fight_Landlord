defmodule RawWeb.AuthPlugs do
  import Plug.Conn
  import Phoenix.Controller
  alias Raw.Accounts.User
  require Logger
  def init(options), do: options

  def call(conn, options) do
    token = conn
            |> get_session("token")
    case Phoenix.Token.verify(RawWeb.Endpoint, "salt", token) do
      {:ok, id} ->
        conn
      _ ->
        conn
        |> halt()
        |> assign(:messages, ["please login"])
        |> assign(:changeset, User.changeset(%User{}))
        |> put_layout(false)
        |> put_view(RawWeb.AccountView)
        |> render("index.html")
    end
  end
end
defmodule RawWeb.AccountController do
  use RawWeb, :controller
  alias Raw.Accounts.User
  alias Raw.Repo
  alias Raw.Accounts

  def index(conn, _params) do
    account = User.changeset(%User{})

    conn
    |> put_layout(false)
    |> render("index.html", changeset: account, messages: [])
  end

  def create(conn, params) do
    if Accounts.exist(params) do
      redirect(conn, to: "/game")
    else
      conn
      |> put_layout(false)
      |> assign(:messages, ["auth fail"])
      |> assign(:changeset, User.changeset(%User{}))
      |> render("index.html")
    end
  end
end

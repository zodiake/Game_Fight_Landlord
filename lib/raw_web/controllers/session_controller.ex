defmodule RawWeb.SessionController do
  use RawWeb, :controller
  alias Raw.Accounts

  def create(conn, %{"user" => %{"name" => name, "password" => password}} = param) do
    if Accounts.auth_user(name, password) do
      token = Phoenix.Token.sign(RawWeb.Endpoint, "salt", name)

      conn
      |> put_session(:token, token)
      |> redirect(to: "/hall")
    else
      conn
      |> put_status(401)
      |> put_view(RawWeb.AccountView)
      |> render("index.html", message: ["name or password fail"])
    end
  end
end

defmodule Raw.Accounts do
  alias Raw.Repo
  alias Raw.Accounts.User

  def exist(%{"user" => %{"username" => username, "password" => password}}) do
    source =
      User
      |> Repo.get_by(username: username)

    check(source, password)
  end

  def check(user, password) do
    case user do
      nil ->
        false

      _ ->
        if user.password == password do
          true
        else
          false
        end
    end
  end
end

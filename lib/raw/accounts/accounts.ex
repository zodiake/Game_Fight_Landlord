defmodule Raw.Accounts do
  alias Raw.Repo
  alias Raw.Accounts.User
  @users ~w[tom,mary,peter]

  def auth_user(name, password) do
    user = find_by_name(name)
    if password == user.password do
      true
    else
      false
    end
  end

  def find_by_name(name) do
    Repo.get_by(User, name: name)
  end
end

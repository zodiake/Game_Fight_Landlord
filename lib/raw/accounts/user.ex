defmodule Raw.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user" do
    field :username, :string
    field :password, :string, virtual: true

    timestamps()
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> unique_constraint(:username)
  end
end

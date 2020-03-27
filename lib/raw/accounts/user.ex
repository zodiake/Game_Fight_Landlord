defmodule Raw.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user" do
    field :name, :string
    field :password, :string, virtual: true

    timestamps()
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:name, :password])
    |> validate_required([:name, :password])
    |> unique_constraint(:name)
  end
end

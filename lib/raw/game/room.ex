defmodule Raw.Game.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias Raw.Game.Card

  schema "room" do
    field :room_number, :integer
  end

  def changeset(room, attrs \\ %{}) do
    room
    |> cast(attrs, [:room_number])
  end
end

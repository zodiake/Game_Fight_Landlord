defmodule RawWeb.GameLive do
  use Phoenix.LiveView
  alias Raw.Accounts.User
  alias Raw.Game.{Room, Card}


  def render(assigns) do
    RawWeb.GameView.render("index.html", assigns)
  end

  def mount(_params, _, socket) do
    changeset = Room.changeset(%Room{}, %{})
    ns = socket
         |> assign(:changeset, changeset)
         |> assign(:cards, Enum.take(Card.new(), 12))

    {:ok, ns}
  end

  def handle_event("card_click", %{"v" => value, "color" => color} = param, socket) do
    cards_clicked = Enum.map(socket.assigns.cards, &Card.update_class(&1, param))
    ns = socket
         |> assign(:changeset, socket.assigns.changeset)
         |> assign(:cards, cards_clicked)
    {:noreply, ns}
  end

end

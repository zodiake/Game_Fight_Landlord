defmodule RawWeb.GameLive do
  use Phoenix.LiveView

  def render(assigns) do
    RawWeb.GameView.render("index.html", assigns)
  end

  def mount(_params, _, socket) do
    if connected?(socket), do: :timer.send_interval(3000, self(), :update)

    {:ok, assign(socket, :test, 1)}
  end

  def handle_info(:update, socket) do
    temperature = 2
    {:noreply, assign(socket, :test, temperature)}
  end
end
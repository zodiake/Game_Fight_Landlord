defmodule RawWeb.GameLive do
  use Phoenix.LiveView

  def render(assigns) do
    RawWeb.PageView.render("index.html", assigns)
  end

  def mount(_params, _, socket) do
    {:ok, assign(socket, :test, 1)}
  end
end
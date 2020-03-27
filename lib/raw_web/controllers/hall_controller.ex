defmodule RawWeb.HallController do
  use RawWeb, :controller
  plug RawWeb.AuthPlugs when action in [:index]

  def index(conn, _param) do
    render(conn, "index.html")
  end
end

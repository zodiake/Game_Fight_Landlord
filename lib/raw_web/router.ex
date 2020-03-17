defmodule RawWeb.Router do
  use RawWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    #plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_live_layout, {RawWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug Plug.Parsers,
         parsers: [:urlencoded, :multipart, :json],
         pass: ["*/*"],
         json_decoder: Jason
  end

  scope "/", RawWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/account", AccountController,:index
    post "/account", AccountController, :create
    live "/game", GameLive
  end

  scope "/game", RawWeb do
    pipe_through :api

    post "/:id", GameController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", RawWeb do
  #   pipe_through :api
  # end
end

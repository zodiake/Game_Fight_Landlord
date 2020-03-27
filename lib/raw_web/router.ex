defmodule RawWeb.Router do
  use RawWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    # plug :fetch_flash
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


  scope "/api", RawWeb do
    pipe_through :api

    get "/game", GameController, :index
    post "/game/:id", GameController, :create
    get "/game/:id", GameController, :show
    post "/login", SessionController, :create
  end

  scope "/", RawWeb do
    pipe_through :browser

    get "/", AccountController, :index
    post "/", AccountController, :create
    get "/hall", HallController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", RawWeb do
  #   pipe_through :api
  # end
end

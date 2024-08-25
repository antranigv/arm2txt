defmodule Arm2txtWeb.Router do
  use Arm2txtWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "sse"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Arm2txtWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Hypa.Plug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Arm2txtWeb do
    pipe_through :browser

    get  "/",         PageController, :home
    post "/submit",   PageController, :submit
    get  "/poll/:id", PageController, :poll
  end

  # Other scopes may use custom stacks.
  # scope "/api", Arm2txtWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:arm2txt, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Arm2txtWeb.Telemetry
    end
  end
end

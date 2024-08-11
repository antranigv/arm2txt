defmodule Arm2txtWeb.Router do
  use Arm2txtWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Arm2txtWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :detect_htmx_request
    plug :htmx_layout
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # These functions detect an HTMX request and set the proper assigns for
  # future use
  def detect_htmx_request(conn, _opts) do
    if get_req_header(conn, "hx-request") == ["true"] do
      assign(conn, :htmx, %{
        request: true,
        boosted: get_req_header(conn, "hx-boosted") != [],
        current_url: List.first(get_req_header(conn, "hx-current-url")),
        history_restore_request: get_req_header(conn, "hx-history-restore-request") == ["true"],
        prompt: List.first(get_req_header(conn, "hx-prompt")),
        target: List.first(get_req_header(conn, "hx-target")),
        trigger_name: List.first(get_req_header(conn, "hx-trigger-name")),
        trigger: List.first(get_req_header(conn, "hx-trigger"))
      })
    else
      conn
    end
  end
  def htmx_layout(conn, _opts) do
    if get_in(conn.assigns, [:htmx, :request]) do
      conn = put_root_layout(conn, html: false)

      if conn.assigns.htmx[:boosted] or conn.assigns.htmx[:history_restore_request] do
        put_layout(conn, html: {Arm2txtWeb.Layouts, :app})
      else
        put_layout(conn, html: false)
      end
    else
      conn
      |> put_root_layout(html: {Arm2txtWeb.Layouts, :root})
      |> put_layout(html: {Arm2txtWeb.Layouts, :app})
    end
  end

  scope "/", Arm2txtWeb do
    pipe_through :browser

    get  "/", PageController, :home
    post "/submit", PageController, :submit
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
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

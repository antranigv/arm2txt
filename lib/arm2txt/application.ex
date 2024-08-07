defmodule Arm2txt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Arm2txtWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:arm2txt, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Arm2txt.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Arm2txt.Finch},
      # Start a worker by calling: Arm2txt.Worker.start_link(arg)
      # {Arm2txt.Worker, arg},
      # Start to serve requests, typically the last entry
      Arm2txtWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Arm2txt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Arm2txtWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

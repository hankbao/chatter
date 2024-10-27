defmodule Chatter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChatterWeb.Telemetry,
      Chatter.Repo,
      {DNSCluster, query: Application.get_env(:chatter, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Chatter.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Chatter.Finch},
      # Start a worker by calling: Chatter.Worker.start_link(arg)
      # {Chatter.Worker, arg},
      # Start to serve requests, typically the last entry
      ChatterWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

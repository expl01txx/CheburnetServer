defmodule CheburnetServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    redis_config = Application.get_env(:cheburnet_server, CheburnetServer.Redis, [])
    host = Keyword.get(redis_config, :host, "localhost")

    children = [
      CheburnetServer.Repo,
      {DNSCluster, query: Application.get_env(:cheburnet_server, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CheburnetServer.PubSub},
      # Start a worker by calling: CheburnetServer.Worker.start_link(arg)
      # {CheburnetServer.Worker, arg},
      # Start to serve requests, typically the last entry
      {Redix, name: :redis, host: host, port: 6379},
      {Cachex, name: :local_cache},
      CheburnetServerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CheburnetServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CheburnetServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

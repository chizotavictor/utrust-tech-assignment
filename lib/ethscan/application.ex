defmodule Ethscan.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      EthscanWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ethscan.PubSub},
      # Start the Endpoint (http/https)
      EthscanWeb.Endpoint
      # Start a worker by calling: Ethscan.Worker.start_link(arg)
      # {Ethscan.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ethscan.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EthscanWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule PomTeams.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      PomTeams.Repo,
      # Start the endpoint when the application starts
      PomTeamsWeb.Endpoint,
      # Start a supervisor for pomodoro timers management
      PomTeams.PomTimerContext.PomTimerSupervisor,
      # A registry for pomodoro timers
      {Registry, [keys: :unique, name: PomTeams.PomTimerContext.PomTimersRegistry]}
    ]

    opts = [strategy: :one_for_one, name: PomTeams.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PomTeamsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

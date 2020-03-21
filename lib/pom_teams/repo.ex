defmodule PomTeams.Repo do
  use Ecto.Repo,
    otp_app: :pom_teams,
    adapter: Ecto.Adapters.Postgres
end

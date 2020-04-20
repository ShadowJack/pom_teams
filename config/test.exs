use Mix.Config

# Configure your database
config :pom_teams, PomTeams.Repo,
  username: "postgres",
  password: "postgres",
  database: "pom_teams_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pom_teams, PomTeamsWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Dependency injection
config :pom_teams, :message_sender, PomTeams.Fakes.MessageSenderMock

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :pom_teams,
  ecto_repos: [PomTeams.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :pom_teams, PomTeamsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FpzsEe3oQeJDj5wzQyXU8wccOknQqaTd8oCHKW45Pa49mtSPvIiEwN62X9SgggGh",
  render_errors: [view: PomTeamsWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: PomTeams.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "0lk3mKyV"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure MicrosoftBot service
config :ex_microsoftbot,
    app_id: "",
    app_password: "",
    using_bot_emulator: true


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"


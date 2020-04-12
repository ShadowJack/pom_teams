import Config

# Configure MicrosoftBot service
config :ex_microsoftbot,
  app_id: System.fetch_env!("BOT_APP_ID"),
  app_password: System.fetch_env!("BOT_APP_PASSWORD")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :pom_teams, PomTeamsWeb.Endpoint,
  server: true,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base,
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443]

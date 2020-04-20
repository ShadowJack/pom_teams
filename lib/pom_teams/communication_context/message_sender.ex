defmodule PomTeams.CommunicationContext.MessageSender do
  @moduledoc """
  A behaviour for an http client that sends
  messages to Microsoft Bot Service
  """
  alias PomTeams.UserContext.User

  @doc """
  Send a text message to a user
  """
  @callback send_text(
              user :: User.t(),
              service_url :: String.t(),
              conversation_id :: String.t(),
              bot_id :: String.t(),
              text :: String.t()
            ) :: :ok | :error

  @doc """
  Send a text reply to incoming activity
  """
  @callback reply_with_text(
              activity :: ExMicrosoftBot.Models.Activity.t(),
              text :: String.t()
            ) :: :ok | :error
end

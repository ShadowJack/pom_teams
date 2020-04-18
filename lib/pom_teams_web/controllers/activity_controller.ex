defmodule PomTeamsWeb.ActivityController do
  @moduledoc """
  Controller for handling conversations with MS Teams
  """
  use PomTeamsWeb, :controller
  alias ExMicrosoftBot.Models.Activity
  alias PomTeams.InputHandler

  require Logger

  @spec new(Plug.Conn.t(), binary | map) :: Plug.Conn.t()
  def new(conn, params) do
    {:ok, activity} = Activity.parse(params)

    result = InputHandler.handle_activity(activity)
    send_resp_for_activity(conn, activity, result)
  end

  @spec send_resp_for_activity(Plug.Conn.t(), Activity.t(), InputHandler.response()) ::
          Plug.Conn.t()
  defp send_resp_for_activity(conn, activity, {result_atom, msg}) do
    send_reply_to_chat(activity, msg)

    resp_code =
      case result_atom do
        :ok -> 200
        :client_error -> 400
        :server_error -> 500
      end

    send_resp(conn, resp_code, msg)
  end

  @spec send_reply_to_chat(Activity.t(), String.t()) ::
          :ok | ExMicrosoftBot.Client.error_type()
  defp send_reply_to_chat(activity, message) do
    resp_activity = %Activity{
      type: "message",
      conversation: activity.conversation,
      recipient: activity.from,
      from: activity.recipient,
      replyToId: activity.id,
      text: message
    }

    ExMicrosoftBot.Client.Conversations.reply_to_activity(
      activity.serviceUrl,
      activity.conversation.id,
      activity.id,
      resp_activity
    )
  end
end

defmodule PomTeams.CommunicationContext.MessageSenderImpl do
  @moduledoc """
  A default implementation for `PomTeams.CommunicationContext.MessageSender` behaviour
  """

  alias PomTeams.CommunicationContext.MessageSender
  alias ExMicrosoftBot.Client.Conversations, as: ConversationsClient
  alias ExMicrosoftBot.Models.Activity

  require Logger

  @behaviour MessageSender

  @doc """
  Send a text message to user
  """
  @impl MessageSender
  def send_text(user, service_url, conversation_id, bot_id, text) do
    activity = %Activity{
      type: "message",
      serviceUrl: service_url,
      conversation: %ExMicrosoftBot.Models.ConversationAccount{
        id: conversation_id
      },
      recipient: %ExMicrosoftBot.Models.ChannelAccount{
        id: user.id,
        name: user.name
      },
      from: %ExMicrosoftBot.Models.ChannelAccount{
        id: bot_id,
        name: "PomBot"
      },
      text: text
    }

    case ConversationsClient.send_to_conversation(conversation_id, activity) do
      :ok ->
        :ok

      error ->
        Logger.error("Error sending message to the user: #{inspect(error)}")
        :error
    end
  end

  @doc """
  Send a text reply to incoming activity
  """
  @impl MessageSender
  def reply_with_text(activity, text) do
    resp_activity = %Activity{
      type: "message",
      conversation: activity.conversation,
      recipient: activity.from,
      from: activity.recipient,
      replyToId: activity.id,
      text: text
    }

    case ExMicrosoftBot.Client.Conversations.reply_to_activity(
           activity.serviceUrl,
           activity.conversation.id,
           activity.id,
           resp_activity
         ) do
      :ok ->
        :ok

      error ->
        Logger.error("Error sending reply to the user: #{inspect(error)}")
        :error
    end
  end
end

defmodule PomTeams.InputHandler do
  @moduledoc """
  Functionality for handling incoming messages from user
  """

  require Logger

  alias ExMicrosoftBot.Models.Activity
  alias PomTeams.UserContext
  alias PomTeams.PomTimerContext.{PomTimer, PomTimerSupervisor}

  @type response ::
          {:ok, String.t()}
          | {:client_error, String.t()}
          | {:server_error, String.t()}

  @doc """
  Handle activity
  """
  @spec handle_activity(Activity.t()) :: InputHandler.response()
  def handle_activity(activity) do
    case parse_command(activity.text) do
      {:ok, cmd} -> handle_command(cmd, activity)
      :error -> {:client_error, "Sorry, I don't understand :("}
    end
  end

  @spec parse_command(String.t()) :: {:ok, atom} | :error
  defp parse_command(text) do
    normalized =
      text
      |> String.trim()
      |> String.downcase()

    case normalized do
      "pomstart" -> {:ok, :start}
      "pompause" -> {:ok, :pause}
      "pomreset" -> {:ok, :reset}
      "pomstop" -> {:ok, :stop}
      _ -> :error
    end
  end

  @spec handle_command(atom(), Activity.t()) :: InputHandler.response()
  defp handle_command(:start, activity) do
    handle_command(:start, activity, fn _ ->
      user =
        UserContext.get_or_create!(
          activity.from.id,
          activity.from.name
        )

      # start a timer
      bot_id = activity.recipient.id
      service_url = activity.serviceUrl
      conversation_id = activity.conversation.id
      {:ok, pid} = PomTimerSupervisor.create_pom_timer(user, service_url, conversation_id, bot_id )

      PomTimer.start(pid)
    end)
  end

  defp handle_command(command, activity) do
    handle_command(command, activity, fn _ ->
      {:client_error,
       "No pomodoro timer is running. You can start a new one with 'pomstart' command."}
    end)
  end

  @spec handle_command(atom(), Activity.t(), (Activity.t() -> InputHandler.response())) ::
          InputHandler.response()
  defp handle_command(command, activity, on_timer_not_found) do
    user_external_id = activity.from.id

    case PomTimerSupervisor.get_pom_timer(user_external_id) do
      nil ->
        on_timer_not_found.(activity)

      pid ->
        res = apply(PomTimer, command, [pid])
        Logger.info("Result of a timer command processing: #{inspect(res)}")
        res
    end
  end
end

defmodule PomTeams.InputHandler do
  @moduledoc """
  Functionality for handling incoming messages from user
  """

  alias ExMicrosoftBot.Models.Activity

  alias PomTeams.UserContext,
        alias(PomTeams.PomTimerContext.{PomTimer, PomTimerSupervisor})

  @doc """
  Handle activity
  """
  @spec handle_activity(Activity.t()) ::
          :ok
          | {:client_error, String.t()}
          | {:server_error, String.t()}
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

  @spec handle_command(atom(), Activity.t()) ::
          :ok
          | {:client_error, String.t()}
          | {:server_error, String.t()}
  defp handle_command(:start, activity) do
    # get pomodoro timer
    user_external_id = activity.from.id

    case PomTimerSupervisor.get_pom_timer(user_external_id) do
      nil ->
        user =
          UserContext.get_or_create!(
            activity.from.id,
            activity.from.name,
            activity.conversation.id
          )

        # start a timer
        bot_id = activity.recipient.id
        PomTimerSupervisor.create_pom_timer(user, bot_id)
        :ok

      pid ->
        PomTimer.start(pid)
    end
  end

  # TODO: implement
  defp handle_command(_, _), do: :ok
end

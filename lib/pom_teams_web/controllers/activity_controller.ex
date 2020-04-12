defmodule PomTeamsWeb.ActivityController do
  @moduledoc """
  Controller for handling conversations with MS Teams
  """
  use PomTeamsWeb, :controller
  alias ExMicrosoftBot.Models.Activity

  require Logger

  def new(conn, params) do
    {:ok, activity} = Activity.parse(params)

    user =
      PomTeams.UserContext.get_or_create!(
        activity.from.id,
        activity.from.name,
        activity.conversation.id
      )

    #TODO: parse command and pass it to correct timer

    # start a timer
    bot_id = activity.recipient.id
    PomTeams.PomTimer.start_link(user, bot_id)
    send_resp(conn, 200, "")
  end
end

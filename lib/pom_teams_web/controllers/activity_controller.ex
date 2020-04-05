defmodule PomTeamsWeb.ActivityController do
  @moduledoc """
  Controller for handling conversations with MS Teams
  """
  use PomTeamsWeb, :controller
  alias ExMicrosoftBot.Models.Activity

  require Logger
  
  def new(conn, params) do
    Logger.info(inspect(params))

    activity = Activity.parse(params)
    Logger.info(inspect(activity))

    send_resp(conn, 200, "")
  end
end

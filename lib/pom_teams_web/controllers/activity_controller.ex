defmodule PomTeamsWeb.ActivityController do
  @moduledoc """
  Controller for handling conversations with MS Teams
  """
  use PomTeamsWeb, :controller
  alias ExMicrosoftBot.Models.Activity
  alias PomTeams.InputHandler

  require Logger

  def new(conn, params) do
    Logger.info(inspect(params))
    {:ok, activity} = Activity.parse(params)

    case InputHandler.handle_activity(activity) do
      :ok -> send_resp(conn, 200, "")
      {:client_error, msg} -> send_resp(conn, 400, msg)
      {:server_error, msg} -> send_resp(conn, 500, msg)
    end
  end
end

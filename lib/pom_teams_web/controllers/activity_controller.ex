defmodule PomTeamsWeb.ActivityController do
  @moduledoc """
  Controller for handling conversations with MS Teams
  """
  use PomTeamsWeb, :controller

  require Logger
  
  def new(conn, params) do
    Logger.info(inspect(params))
    send_resp(conn, 200, "")
  end
end

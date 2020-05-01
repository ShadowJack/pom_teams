defmodule PomTeamsWeb.Router do
  use PomTeamsWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  if Mix.env() == :dev do
    scope "/" do
      live_dashboard "/dashboard"
    end
  end

  scope "/api", PomTeamsWeb do
    pipe_through :api

    post "/activity", ActivityController, :new
  end
end

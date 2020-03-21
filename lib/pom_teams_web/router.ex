defmodule PomTeamsWeb.Router do
  use PomTeamsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PomTeamsWeb do
    pipe_through :api
  end
end

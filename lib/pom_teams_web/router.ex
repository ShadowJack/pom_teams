defmodule PomTeamsWeb.Router do
  use PomTeamsWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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

  scope "/", PomTeamsWeb do
    pipe_through :browser

    get "/settings", UserSettingsController, :show
    get "/settings/:id/edit", UserSettingsController, :edit
    put "/settings/:id", UserSettingsController, :update
  end
end

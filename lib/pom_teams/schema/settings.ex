defmodule PomTeams.Schema.Settings do
  @moduledoc """
  Schema for user settings
  """
  use Ecto.Schema

  schema "settings" do

    belongs_to :user, PomTeams.Schema.User

    # time interval for the pomodoro
    field :pomodoro_minutes, :integer

    # time interval for a short break
    field :short_break_minutes, :integer
 
    # time interval for a long break
    field :long_break_minutes, :integer

    # number of pomodoros before a long break 
    field :short_breaks_limit, :integer
  end
end

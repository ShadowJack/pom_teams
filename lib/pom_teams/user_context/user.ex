defmodule PomTeams.UserContext.User do
  @moduledoc """
  Schema for a user
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    # id of the user in external system(MS Teams)
    field :external_id, :string

    # user name
    field :name, :string

    # time interval for the pomodoro
    field :pomodoro_minutes, :integer

    # time interval for a short break
    field :short_break_minutes, :integer

    # time interval for a long break
    field :long_break_minutes, :integer

    # number of pomodoros before a long break 
    field :short_breaks_limit, :integer
  end

  @doc """
  A changeset for user creation
  """
  @spec changeset_for_create(User.t(), String.t(), String.t()) :: Ecto.Changeset.t()
  def changeset_for_create(user, external_id, name) do
    params = %{external_id: external_id, name: name}

    user
    |> cast(params, [:external_id, :name])
    |> validate_required([:external_id])
  end

  @doc """
  A changeset for settings editing
  """
  @spec change_settings(User.t(), Map.t()) :: Ecto.Changeset.t()
  def change_settings(user, params) do
    user
    |> cast(params, [:pomodoro_minutes, :short_break_minutes, :long_break_minutes, :short_breaks_limit])
    |> validate_number(:pomodoro_minutes, greater_than: 0, less_than: 24 * 60, message: "One pomodoro round should be more than 1 minute and less than 1 day")
    |> validate_number(:short_break_minutes, greater_than: 0, less_than: 24 * 60, message: "A short break should be more than 1 minute and less than 1 day")
    |> validate_number(:long_break_minutes, greater_than: 0, less_than: 24 * 60, message: "A long break should be more than 1 minute and less than 1 day")
  end
end

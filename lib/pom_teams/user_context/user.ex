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

    # id of the last conversation with this user
    field :conversation_id, :string

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
  @spec changeset_for_create(User.t(), String.t(), String.t(), String.t()) :: Ecto.Changeset.t()
  def changeset_for_create(user, external_id, name, conversation_id) do
    params = %{external_id: external_id, name: name, conversation_id: conversation_id}

    user
    |> cast(params, [:external_id, :name, :conversation_id])
    |> validate_required([:external_id, :conversation_id])
  end
end

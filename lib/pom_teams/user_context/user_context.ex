defmodule PomTeams.UserContext do
  @moduledoc """
  A user-related logic
  """

  alias PomTeams.Repo
  alias PomTeams.UserContext.User

  @doc """
  Get or create a user by `external_user_id`.
  If user doesn't exist a new user is created with the `user_name` provided.
  """
  @spec get_or_create!(String.t(), String.t()) :: User.t()
  def get_or_create!(external_user_id, user_name) do
    case Repo.get_by(User, external_id: external_user_id) do
      nil ->
        {:ok, created} = create!(external_user_id, user_name)
        Repo.get_by(User, id: created.id)

      user ->
        user
    end
  end

  @doc """
  Create a user.
  """
  @spec create!(String.t(), String.t()) :: User.t()
  def create!(external_user_id, user_name) do
    %User{}
    |> User.changeset_for_create(external_user_id, user_name)
    |> Repo.insert(
      on_conflict: {:replace, [:name]},
      conflict_target: [:external_id]
    )
  end
end

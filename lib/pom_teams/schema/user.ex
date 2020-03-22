defmodule PomTeams.Schema.User do
  @moduledoc """
  Schema for a user
  """
  use Ecto.Schema

  schema "users" do
    field :name, :string
  end
end

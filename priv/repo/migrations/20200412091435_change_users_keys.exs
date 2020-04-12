defmodule PomTeams.Repo.Migrations.ChangeUsersKeys do
  use Ecto.Migration

  def change do
    drop table("users")

    create table("users", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :external_id, :string, null: false
      add :name, :string
      add :conversation_id, :string, null: false
      add :pomodoro_minutes, :integer, null: false, default: 25
      add :short_break_minutes, :integer, null: false, default: 5
      add :long_break_minutes, :integer, null: false, default: 15
      add :short_breaks_limit, :integer, null: false, default: 4
    end
  end
end

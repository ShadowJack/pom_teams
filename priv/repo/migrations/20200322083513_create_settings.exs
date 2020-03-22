defmodule PomTeams.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table("settings") do
      add :user_id, references("users"), on_delete: :delete_all
      add :pomodoro_minutes, :integer
      add :short_break_minutes, :integer
      add :long_break_minutes, :integer
      add :short_breaks_limit, :integer
    end
  end
end

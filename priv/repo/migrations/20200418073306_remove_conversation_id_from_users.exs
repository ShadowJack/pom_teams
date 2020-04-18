defmodule PomTeams.Repo.Migrations.RemoveConversationIdFromUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      remove :conversation_id, :string
    end
  end
end

defmodule PomTeams.UserContextTest do
  use PomTeams.DataCase, async: false

  alias PomTeams.UserContext
  alias PomTeams.UserContext.User

  test "user is created and retrieved if it doesn't exist" do
    %User{external_id: external_id, name: name} = build_user()

    assert %User{
             external_id: external_id,
             name: name,
             pomodoro_minutes: 25,
             short_break_minutes: 5,
             long_break_minutes: 15,
             short_breaks_limit: 4
           } = UserContext.get_or_create!(external_id, name)
  end

  test "user is retrieved if it exists" do
    created = Repo.insert!(build_user())

    retrieved = UserContext.get_or_create!(created.external_id, "some name")
    assert created.id == retrieved.id
    assert created.external_id == retrieved.external_id
    assert created.name == retrieved.name
  end

  defp build_user() do
    %User{
      external_id: "test_#{Ecto.UUID.generate()}",
      name: "Test user"
    }
  end
end

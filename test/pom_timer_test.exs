defmodule PomTeams.PomTimerTest do
  use ExUnit.Case, async: true

  alias PomTeams.PomTimer
  alias PomTeams.Schema.Settings

  test "state machine is running after creation" do
    settings = %Settings{build_settings() | pomodoro_minutes: 10}

    assert {:ok, statem} = PomTimer.start_link(settings)
    assert :running == PomTimer.get_state(statem)
  end

  describe "start action" do

    test "sets up the timer" do
      # {:ok, statem} = PomTimer.start_link(build_settings())
      # 
      # #TODO: check the current time is not null
      # assert PomTimer.get_time_elapsed(statem) > 0
    end
  end

  defp build_settings() do
    %Settings
    {
      user_id: 1,
      pomodoro_minutes: 0,
      short_break_minutes: 1,
      long_break_minutes: 2,
      short_breaks_limit: 1
    }
  end
end

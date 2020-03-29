defmodule PomTeams.PomTimerTest do
  use ExUnit.Case, async: true

  alias PomTeams.PomTimer
  alias PomTeams.Schema.Settings

  test "state machine is running after creation" do
    assert {:ok, timer} = PomTimer.start_link(build_settings())
    assert :running == PomTimer.get_state(timer)

    Process.sleep(1500)
    assert PomTimer.get_seconds_elapsed(timer) > 0
  end

  test "pause action pauses the timer" do
    {:ok, timer} = PomTimer.start_link(build_settings())

    PomTimer.pause(timer)
    prev_seconds_elapsed = PomTimer.get_seconds_elapsed(timer)

    Process.sleep(1500)

    assert :stopped == PomTimer.get_state(timer)
    assert PomTimer.get_seconds_elapsed(timer) == prev_seconds_elapsed
  end

  test "start action unpauses the timer" do
    {:ok, timer} = PomTimer.start_link(build_settings())
    Process.sleep(1500)
    PomTimer.pause(timer)
    prev_seconds_elapsed = PomTimer.get_seconds_elapsed(timer)

    # unpause
    PomTimer.start(timer)
    Process.sleep(1500)

    assert PomTimer.get_seconds_elapsed(timer) > prev_seconds_elapsed
  end

  defp build_settings() do
    %Settings{
      user_id: 1,
      pomodoro_minutes: 10,
      short_break_minutes: 1,
      long_break_minutes: 2,
      short_breaks_limit: 1
    }
  end
end

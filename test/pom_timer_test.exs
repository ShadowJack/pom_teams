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

    assert :stopped == PomTimer.get_state(timer)
    prev_seconds_elapsed = PomTimer.get_seconds_elapsed(timer)

    Process.sleep(1500)

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

  describe "reset action" do
    test "resets the paused timer to initial state" do
      {:ok, timer} = PomTimer.start_link(build_settings())
      Process.sleep(1500)
      PomTimer.pause(timer)

      PomTimer.reset(timer)

      assert PomTimer.get_seconds_elapsed(timer) == 0
      assert PomTimer.get_state(timer) == :stopped

      # TODO: check rounds count was reset 
      # by manually sending :round_finished events
    end

    test "restarts the running timer" do
      {:ok, timer} = PomTimer.start_link(build_settings())
      Process.sleep(2500)

      prev_seconds_elapsed = PomTimer.get_seconds_elapsed(timer)

      PomTimer.reset(timer)

      assert PomTimer.get_seconds_elapsed(timer) < prev_seconds_elapsed
      assert PomTimer.get_state(timer) == :running

      # TODO: check rounds count was reset 
      # by manually sending :round_finished events
    end
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

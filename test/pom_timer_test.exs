defmodule PomTeams.PomTimerTest do
  use ExUnit.Case, async: true

  alias PomTeams.PomTimer
  alias PomTeams.Schema.Settings

  test "state machine is running after creation" do
    assert {:ok, timer} = PomTimer.start_link(build_settings())
    assert {:ok, :running} == PomTimer.get_state(timer)

    Process.sleep(1500)
    assert {:ok, seconds} = PomTimer.get_seconds_elapsed(timer)
    assert seconds > 0
  end

  test "pause action pauses the timer" do
    {:ok, timer} = PomTimer.start_link(build_settings())

    PomTimer.pause(timer)

    assert {:ok, :stopped} == PomTimer.get_state(timer)
    {:ok, prev_seconds_elapsed} = PomTimer.get_seconds_elapsed(timer)

    Process.sleep(1500)

    {:ok, seconds_elapsed} = PomTimer.get_seconds_elapsed(timer)
    assert prev_seconds_elapsed == seconds_elapsed
  end

  test "start action unpauses the timer" do
    {:ok, timer} = PomTimer.start_link(build_settings())
    Process.sleep(1500)
    PomTimer.pause(timer)
    {:ok, prev_seconds_elapsed} = PomTimer.get_seconds_elapsed(timer)

    # unpause
    PomTimer.start(timer)
    Process.sleep(1500)

    {:ok, seconds_elapsed} = PomTimer.get_seconds_elapsed(timer)
    assert seconds_elapsed > prev_seconds_elapsed
  end

  describe "reset action" do
    test "resets the paused timer to initial state" do
      {:ok, timer} = PomTimer.start_link(build_settings())
      Process.sleep(1500)
      PomTimer.pause(timer)

      PomTimer.reset(timer)

      assert {:ok, 0} = PomTimer.get_seconds_elapsed(timer)
      assert {:ok, :stopped} = PomTimer.get_state(timer)

      # TODO: check rounds count was reset 
      # by manually sending :round_finished events
    end

    test "restarts the running timer" do
      {:ok, timer} = PomTimer.start_link(build_settings())
      Process.sleep(2500)

      {:ok, prev_seconds_elapsed} = PomTimer.get_seconds_elapsed(timer)

      PomTimer.reset(timer)

      {:ok, seconds_elapsed} = PomTimer.get_seconds_elapsed(timer)
      assert seconds_elapsed < prev_seconds_elapsed
      assert {:ok, :running} = PomTimer.get_state(timer)

      # TODO: check rounds count was reset 
      # by manually sending :round_finished events
    end
  end

  test "stop action pauses and resets everything" do
    {:ok, timer} = PomTimer.start_link(build_settings())
    Process.sleep(1500)

    PomTimer.stop(timer)

    assert {:ok, 0} = PomTimer.get_seconds_elapsed(timer)
    assert {:ok, :stopped} = PomTimer.get_state(timer)

    # TODO: check rounds count was reset 
    # by manually sending :round_finished events
  end

  describe "when round is finished" do
    test "count of completed rounds is increased" do
      {:ok, timer} = PomTimer.start_link(build_settings())

      Process.send(timer, :round_finished, [])

      assert {:ok, 1} == PomTimer.get_rounds_finished(timer)
    end

    test "a short break is started" do
      {:ok, timer} = PomTimer.start_link(build_settings())

      Process.send(timer, :round_finished, [])
      Process.sleep(1500)

      assert {:ok, :on_break} = PomTimer.get_state(timer)
      assert {:ok, seconds} = PomTimer.get_seconds_elapsed(timer)
      assert seconds > 0
    end

    test "a long break is started" do
      settings = %Settings{ build_settings() | short_break_minutes: 0}
      {:ok, timer} = PomTimer.start_link(settings)

      Process.send(timer, :round_finished, [])
      # skip the short break
      Process.sleep(1500)
      assert {:ok, :running} = PomTimer.get_state(timer)

      Process.send(timer, :round_finished, [])
      Process.sleep(1500)

      # check that long break is active
      assert {:ok, :on_break} = PomTimer.get_state(timer)
      assert {:ok, seconds} = PomTimer.get_seconds_elapsed(timer)
      assert seconds > 0
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

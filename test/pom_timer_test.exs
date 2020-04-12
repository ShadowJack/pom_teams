defmodule PomTeams.PomTimerTest do
  use ExUnit.Case, async: true

  alias PomTeams.PomTimerContext.{PomTimer, PomTimerSupervisor}
  alias PomTeams.UserContext.User

  test "state machine is running after creation" do
    timer = start_timer_link()
    assert {:ok, :running} == PomTimer.get_state(timer)

    Process.sleep(1500)
    assert {:ok, seconds} = PomTimer.get_seconds_elapsed(timer)
    assert seconds > 0
  end

  test "pause action pauses the timer" do
    timer = start_timer_link()

    PomTimer.pause(timer)

    assert {:ok, :stopped} == PomTimer.get_state(timer)
    {:ok, prev_seconds_elapsed} = PomTimer.get_seconds_elapsed(timer)

    Process.sleep(1500)

    {:ok, seconds_elapsed} = PomTimer.get_seconds_elapsed(timer)
    assert prev_seconds_elapsed == seconds_elapsed
  end

  test "start action unpauses the timer" do
    timer = start_timer_link()
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
      timer = start_timer_link()
      Process.sleep(1500)
      PomTimer.pause(timer)

      PomTimer.reset(timer)

      assert {:ok, 0} = PomTimer.get_seconds_elapsed(timer)
      assert {:ok, :stopped} = PomTimer.get_state(timer)

      # TODO: check rounds count was reset 
      # by manually sending :round_finished events
    end

    test "restarts the running timer" do
      timer = start_timer_link()
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
    timer = start_timer_link()
    Process.sleep(1500)

    PomTimer.stop(timer)

    assert {:ok, 0} = PomTimer.get_seconds_elapsed(timer)
    assert {:ok, :stopped} = PomTimer.get_state(timer)

    # TODO: check rounds count was reset 
    # by manually sending :round_finished events
  end

  describe "when round is finished" do
    test "count of completed rounds is increased" do
      timer = start_timer_link()

      Process.send(timer, :round_finished, [])

      assert {:ok, 1} == PomTimer.get_rounds_finished(timer)
    end

    test "a short break is started" do
      timer = start_timer_link()

      Process.send(timer, :round_finished, [])
      Process.sleep(1500)

      assert {:ok, :on_break} = PomTimer.get_state(timer)
      assert {:ok, seconds} = PomTimer.get_seconds_elapsed(timer)
      assert seconds > 0
    end

    test "a long break is started" do
      user = %User{build_user() | short_break_minutes: 0}
      timer = start_timer_link(user)

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

  defp start_timer_link(user \\ build_user()) do
    assert {:ok, timer} = PomTimer.start_link({user, "xyz"})
    timer
  end

  defp build_user() do
    %User{
      id: "test_user",
      conversation_id: "conversation123",
      name: "Test user",
      pomodoro_minutes: 10,
      short_break_minutes: 1,
      long_break_minutes: 2,
      short_breaks_limit: 1
    }
  end
end

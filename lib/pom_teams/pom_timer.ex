defmodule PomTeams.PomTimer do
  @moduledoc """
  A pomodoro timer state machine
  """
  use GenStateMachine

  alias PomTeams.Schema.Settings

  @type data :: %{
          settings: Settings.t(),
          rounds_finished: number(),
          # Reference to the current timer 
          # that will ring at the end of the round
          timer_ref: :timer.tref() | nil,
          # Seconds left until the end of the round
          # nil at the start when the timer is not started yet
          seconds_left: number() | nil
        }
  @type state :: :stopped | :running

  @state_stopped :stopped
  @state_running :running

  @action_start :start
  @action_pause :pause
  @action_reset :reset
  @action_stop :stop

  ##
  # Interface

  @doc """
  Start a new timer
  """
  @spec start_link(Settings.t()) :: :gen_statem.start_ret()
  def start_link(settings) do
    GenStateMachine.start_link(PomTeams.PomTimer, settings)
  end

  @doc """
  Start the timer
  """
  @spec start(:gen_statem.server_ref()) :: :ok
  def start(pid) do
    GenStateMachine.cast(pid, @action_start)
  end

  @doc """
  Pause the timer
  """
  @spec pause(:gen_statem.server_ref()) :: :ok
  def pause(pid) do
    GenStateMachine.cast(pid, @action_pause)
  end

  @doc """
  Reset the timer
  """
  @spec reset(:gen_statem.server_ref()) :: :ok
  def reset(pid) do
    GenStateMachine.cast(pid, @action_reset)
  end

  @doc """
  Stop the timer: pause and reset to initial state
  """
  @spec stop(:gen_statem.server_ref()) :: :ok
  def stop(pid) do
    GenStateMachine.cast(pid, @action_stop)
  end

  @doc """
  Get current state
  """
  @spec get_state(:gen_statem.server_ref()) :: state()
  def get_state(pid) do
    GenStateMachine.call(pid, :get_state)
  end

  @doc """
  Get seconds elapsed since the start of current pomodoro round
  """
  @spec get_seconds_elapsed(:gen_statem.server_ref()) :: number()
  def get_seconds_elapsed(pid) do
    GenStateMachine.call(pid, :get_seconds_elapsed)
  end

  ##
  # Implementation

  def init(settings) do
    data = %{settings: settings, timer_ref: nil, rounds_finished: 0, seconds_left: nil}
    {:ok, @state_stopped, data, {:next_event, :cast, @action_start}}
  end

  @doc """
  Handle start action
  """
  def handle_event(:cast, @action_start, @state_running, data) do
    {:next_state, @state_running, data}
  end

  def handle_event(:cast, @action_start, @state_stopped, data) do
    {:next_state, @state_running, start_round_timer(data)}
  end

  @doc """
  Handle pause action
  """
  def handle_event(:cast, @action_pause, @state_stopped, data) do
    {:next_state, @state_stopped, data}
  end

  def handle_event(:cast, @action_pause, @state_running, data) do
    {:next_state, @state_stopped, remove_round_timer(data)}
  end

  @doc """
  Handle reset action
  """
  def handle_event(:cast, @action_reset, @state_stopped, data) do
    updated_data =
      data
      |> reset_round()
      |> reset_rounds()

    {:next_state, @state_stopped, updated_data}
  end

  def handle_event(:cast, @action_reset, @state_running, data) do
    updated_data =
      data
      |> remove_round_timer()
      |> reset_round()
      |> reset_rounds()
      |> start_round_timer()

    {:next_state, @state_running, updated_data}
  end

  # @doc """
  # Handle stop action
  # """
  # def handle_event(:cast, @action_stop, @state_running, data) do
  #   updated_data = data
  #     |> remove_round_timer()
  #     |> reset_rounds()
  # 
  #   {:next_state, @state_stopped, updated_data}
  # end
  # def handle_event(:cast, @action_stop, @state_stopped, data) do
  #   updated_data = data
  #     |> reset_rounds()
  # 
  #   {:next_state, @state_stopped, updated_data}
  # end

  @doc """
  Handle state request
  """
  def handle_event({:call, from}, :get_state, state, data) do
    {:next_state, state, data, [{:reply, from, state}]}
  end

  @doc """
  Handle seconds_elapsed request
  """
  def handle_event({:call, from}, :get_seconds_elapsed, state, data) do
    seconds_elapsed = calc_seconds_elapsed(data)
    {:next_state, state, data, [{:reply, from, seconds_elapsed}]}
  end

  @doc """
  Handle finished round event
  """
  def handle_event(:info, :round_finished, state, data) do
    raise "Not implemented"
  end

  @doc """
  Catch-all handler
  """
  def handle_event(action_type, event_content, state, data) do
    # TODO: craches the timer so it should be avoided
    IO.puts("Catching the unknown event")
    super(action_type, event_content, state, data)
  end

  ## Private functions
  #

  defp start_round_timer(%{settings: settings, seconds_left: nil} = data) do
    # start the new round timer
    seconds_left = settings.pomodoro_minutes * 60
    # TODO: monitor the timer reference?
    timer_ref = Process.send_after(self(), :round_finished, seconds_left * 1000)
    %{data | timer_ref: timer_ref, seconds_left: seconds_left}
  end

  defp start_round_timer(%{seconds_left: seconds_left} = data) do
    # restart the existing round timer
    # TODO: monitor the timer reference?
    timer_ref = Process.send_after(self(), :round_finished, seconds_left * 1000)
    %{data | timer_ref: timer_ref}
  end

  defp calc_seconds_elapsed(%{seconds_left: nil}) do
    # round is not started yet
    0
  end

  defp calc_seconds_elapsed(%{settings: settings, seconds_left: seconds_left, timer_ref: nil}) do
    # timer is on pause
    settings.pomodoro_minutes * 60 - seconds_left
  end

  defp calc_seconds_elapsed(%{settings: settings, seconds_left: seconds_left, timer_ref: timer}) do
    # timer is running
    case Process.read_timer(timer) do
      false -> settings.pomodoro_minutes * 60 - seconds_left
      milliseconds -> settings.pomodoro_minutes * 60 - div(milliseconds, 1000)
    end
  end

  defp remove_round_timer(%{timer_ref: nil} = data), do: data

  defp remove_round_timer(%{seconds_left: seconds_left, timer_ref: timer_ref} = data) do
    seconds_left =
      case Process.cancel_timer(timer_ref) do
        false -> seconds_left
        milliseconds -> div(milliseconds, 1000)
      end

    %{data | timer_ref: nil, seconds_left: seconds_left}
  end

  defp reset_round(data) do
    %{data | seconds_left: nil}
  end

  defp reset_rounds(data) do
    %{data | rounds_finished: 0}
  end

  # defp reset_rounds(data) do
  #   %{data | rounds_finished: 0}
  # end
end

defmodule PomTeams.PomTimer do
  @moduledoc """
  A pomodoro timer state machine
  """
  use GenStateMachine

  alias PomTeams.Schema.Settings

  @type data :: %{settings: Settings.t(), timer_ref: :timer.tref() | nil, rounds_finished: number(), time_passed: number()}
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
  @spec start_link(Settings.t) :: :gen_statem.start_ret
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

  ##
  # Implementation

  def init(settings) do
    data = %{settings: settings, timer_ref: nil, rounds_finished: 0, time_passed: 0}
    {:ok, @state_stopped, data, {:next_event, :cast, @action_start}}
  end

  @doc """
  Handle start action
  """
  def handle_event(:cast, @action_start, @state_stopped, data) do
    {:next_state, @state_running, data}
    #TODO: {:next_state, @state_running, start_round_timer(data)}
  end
  
  # @doc """
  # Handle pause action
  # """
  # def handle_event(:cast, @action_pause, @state_running, data) do
  #   {:next_state, @state_stopped, remove_round_timer(data)}
  # end
  # 
  # @doc """
  # Handle reset action
  # """
  # def handle_event(:cast, @action_reset, @state_stopped, data) do
  #   updated_data = data
  #     |> reset_rounds()
  # 
  #   {:next_state, @state_stopped, updated_data}
  # end
  # def handle_event(:cast, @action_reset, @state_running, data) do
  #   updated_data = data
  #     |> remove_round_timer()
  #     |> reset_rounds()
  #     |> start_round_timer()
  # 
  #   {:next_state, @state_running, updated_data}
  # end
  # 
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
    IO.puts("Handling")
    {:next_state, state, data, [{:reply, from, state}]}
  end

  @doc """
  Catch-all handler
  """
  def handle_event(action_type, event_content, state, data) do
    IO.puts("Catching the unknown event")
    super(action_type, event_content, state, data)
  end



  ## Private functions
  #

  # defp start_round_timer(%{settings: %Settings{pomodoro_minutes: minutes} } = data) do
  #   # start a new round timer
  #   #TODO: monitor the timer reference?
  #   timer_ref = Process.send_after(self(), :round_finished, milliseconds)
  #   %{data | timer_ref: timer_ref}
  # end
  # 
  # defp remove_round_timer(%{settings: settings, timer_ref: timer_ref } = data) do
  #   # stop the timer
  #   :timer.cancel(timer_ref)
  #   # TODO: save the time elapsed in the round
  #   # remove timer_ref
  #   updated_data = %{data | timer_ref: nil}
  #   updated_data
  # end
  # 
  # defp reset_rounds(data) do
  #   %{data | rounds_finished: 0}
  # end

end

defmodule PomTeams.PomTimer do
  @moduledoc """
  A pomodoro timer state machine
  """
  use GenStateMachine
  require Logger

  alias PomTeams.UserContext.User
  alias ExMicrosoftBot.Client.Conversations, as: ConversationsClient
  alias ExMicrosoftBot.Models.Activity

  @type data :: %{
          user: User.t(),
          bot_id: String.t(),
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
  @state_on_break :on_break

  @action_start :start
  @action_pause :pause
  @action_reset :reset
  @action_stop :stop

  ##
  # Interface

  @doc """
  Start a new timer
  """
  @spec start_link(User.t(), String.t()) :: :gen_statem.start_ret()
  def start_link(user, bot_id) do
    GenStateMachine.start_link(PomTeams.PomTimer, [user, bot_id])
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
  Get seconds elapsed since the start of current pomodoro round or break
  """
  @spec get_seconds_elapsed(:gen_statem.server_ref()) :: number()
  def get_seconds_elapsed(pid) do
    GenStateMachine.call(pid, :get_seconds_elapsed)
  end

  @doc """
  Get a number of pomodoro rounds completed today
  """
  @spec get_rounds_finished(:gen_statem.server_ref()) :: number()
  def get_rounds_finished(pid) do
    GenStateMachine.call(pid, :get_rounds_finished)
  end

  ##
  # Implementation

  def init([user, bot_id]) do
    data = %{
      user: user,
      bot_id: bot_id,
      timer_ref: nil,
      rounds_finished: 0,
      seconds_left: nil
    }

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
    {:next_state, @state_stopped, remove_internal_timer(data)}
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
      |> remove_internal_timer()
      |> reset_round()
      |> reset_rounds()
      |> start_round_timer()

    {:next_state, @state_running, updated_data}
  end

  @doc """
  Handle stop action
  """
  def handle_event(:cast, @action_stop, @state_running, data) do
    updated_data =
      data
      |> remove_internal_timer()
      |> reset_round
      |> reset_rounds()

    {:next_state, @state_stopped, updated_data}
  end

  def handle_event(:cast, @action_stop, @state_stopped, data) do
    updated_data =
      data
      |> reset_round
      |> reset_rounds()

    {:next_state, @state_stopped, updated_data}
  end

  @doc """
  Handle state request
  """
  def handle_event({:call, from}, :get_state, state, data) do
    {:next_state, state, data, [{:reply, from, {:ok, state}}]}
  end

  @doc """
  Handle seconds_elapsed request
  """
  def handle_event({:call, from}, :get_seconds_elapsed, @state_on_break, data) do
    seconds_elapsed = calc_seconds_elapsed_on_break(data)
    {:next_state, @state_on_break, data, [{:reply, from, {:ok, seconds_elapsed}}]}
  end

  def handle_event({:call, from}, :get_seconds_elapsed, state, data) do
    seconds_elapsed = calc_seconds_elapsed_in_round(data)
    {:next_state, state, data, [{:reply, from, {:ok, seconds_elapsed}}]}
  end

  @doc """
  Handle rounds_finished request
  """
  def handle_event({:call, from}, :get_rounds_finished, state, data) do
    {:next_state, state, data, [{:reply, from, {:ok, data.rounds_finished}}]}
  end

  @doc """
  Handle finished round event
  """
  def handle_event(:info, :round_finished, _state, %{user: user, bot_id: bot_id} = data) do
    updated_data =
      data
      # remove the current timer if it's present
      |> remove_internal_timer()
      # reset seconds left
      |> Map.put(:seconds_left, nil)
      # increase the number of finished rounds
      |> Map.put(:rounds_finished, data.rounds_finished + 1)
      # start the break timer
      |> start_break_timer()

    # TODO: extract into a separate module
    activity = %Activity{
      type: "message",
      conversation: %ExMicrosoftBot.Models.ConversationAccount{
        id: user.conversation_id
      },
      recipient: %ExMicrosoftBot.Models.ChannelAccount{
        id: user.id,
        name: user.name
      },
      from: %ExMicrosoftBot.Models.ChannelAccount{
        id: bot_id,
        name: "PomBot"
      },
      text: """
      Hooray, another pomodoro is finished!
      A well-deserved break for #{calc_seconds_in_break(updated_data)} minutes is starting.
      """
    }

    case ConversationsClient.send_to_conversation(user.conversation_id, activity) do
      :ok -> :ok
      error -> Logger.error("Error sending message to the user: #{inspect(error)}")
    end

    # set correct state
    {:next_state, @state_on_break, updated_data}
  end

  @doc """
  Handle finished break event
  """
  def handle_event(:info, :break_finished, @state_on_break, data) do
    Logger.debug("Break finished!")

    updated_data =
      data
      # remove the current timer if it's present
      |> remove_internal_timer()
      # start the next round
      |> start_round_timer()

    # set correct state
    {:next_state, @state_running, updated_data}
  end

  @doc """
  Catch-all handler
  """
  def handle_event({:call, from}, event_content, state, data) do
    {:next_state, state, data, [{:reply, from, :wrong_event}]}
  end

  def handle_event(event_type, event_content, state, data) do
    Logger.warn("Unknow #{event_type} event is sent to #{__MODULE__}: #{inspect(event_content)}")
    {:next_state, state, data}
  end

  ## Private functions
  #

  defp start_round_timer(%{user: user, seconds_left: nil} = data) do
    # start the new round timer
    seconds_left = user.pomodoro_minutes * 60
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

  defp start_break_timer(data) do
    # find the type of break to start: short or long
    seconds = calc_seconds_in_break(data)

    Logger.debug("Break is starting. It will long #{seconds} seconds.")

    # TODO: monitor the timer reference?
    timer_ref = Process.send_after(self(), :break_finished, seconds * 1000)
    %{data | timer_ref: timer_ref}
  end

  defp calc_seconds_elapsed_in_round(%{seconds_left: nil}) do
    # round is not started yet
    0
  end

  defp calc_seconds_elapsed_in_round(%{user: user, seconds_left: seconds_left, timer_ref: nil}) do
    # timer is on pause
    user.pomodoro_minutes * 60 - seconds_left
  end

  defp calc_seconds_elapsed_in_round(%{user: user, seconds_left: seconds_left, timer_ref: timer}) do
    # timer is running
    case Process.read_timer(timer) do
      false -> user.pomodoro_minutes * 60 - seconds_left
      milliseconds -> user.pomodoro_minutes * 60 - div(milliseconds, 1000)
    end
  end

  defp calc_seconds_elapsed_on_break(%{timer_ref: timer} = data) do
    full_break_seconds = calc_seconds_in_break(data)

    case Process.read_timer(timer) do
      false -> full_break_seconds
      milliseconds -> full_break_seconds - div(milliseconds, 1000)
    end
  end

  defp calc_seconds_in_break(data) do
    is_long_break = rem(data.rounds_finished, data.user.short_breaks_limit + 1) == 0

    if is_long_break do
      data.user.long_break_minutes * 60
    else
      data.user.short_break_minutes * 60
    end
  end

  defp remove_internal_timer(%{timer_ref: nil} = data), do: data

  defp remove_internal_timer(%{seconds_left: seconds_left, timer_ref: timer_ref} = data) do
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
end

defmodule PomTeams.PomTimerContext.PomTimerSupervisor do
  @moduledoc """
  A supervisor for pomodoro timers management
  """

  use DynamicSupervisor

  alias PomTeams.PomTimerContext.PomTimer

  ## 
  # API
  #

  @doc """
  Starts the supervisor
  """
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc """
  Create a new pomodoro timer
  """
  @spec create_pom_timer(User.t(), String.t(), String.t(), String.t()) :: {:ok, pid}
  def create_pom_timer(user, service_url, conversation_id, bot_id) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {PomTimer, {user, service_url, conversation_id, bot_id}}
    )
  end

  @doc """
  Try to get a pomodoro timer.
  If it doesn't exist, then `nil` is returned.
  """
  @spec get_pom_timer(String.t()) :: pid() | nil
  def get_pom_timer(external_user_id) do
    case Registry.lookup(PomTeams.PomTimerContext.PomTimersRegistry, external_user_id) do
      [] -> nil
      [{pid, _}] -> pid
    end
  end

  ##
  # Dynamic supervisor implementation
  #

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

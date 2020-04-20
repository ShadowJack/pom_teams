defmodule PomTeams.Fakes.MessageSenderMock do
  @moduledoc """
  A fake implementation of `PomTeams.CommunicationContext.MessageSender` behaviour
  """

  alias PomTeams.CommunicationContext.MessageSender

  use Agent

  @behaviour MessageSender

  @doc false
  def start_link() do
    Agent.start_link(fn -> [send_text: %{}, reply_with_text: %{}] end, name: __MODULE__)
  end


  @doc false
  @impl MessageSender
  def send_text(user, _service_url, _conversation_id, _bot_id, text) do
    # store last sent message for each user
    Agent.update(__MODULE__, fn state -> 
      Keyword.update!(state, :send_text, &(Map.put(&1, user.id, text)))
    end)
    :ok
  end

  @doc false
  @impl MessageSender
  def reply_with_text(activity, text) do
    # store last sent reply for each user
    Agent.update(__MODULE__, fn state -> 
      Keyword.update!(state, :reply_with_text, &(Map.put(&1, activity.id, text)))
    end)
    :ok
  end

  @doc """
  Inspect the aggregated calls
  """
  @spec get_state() :: [send_text: Map.t(), reply_with_text: Map.t()]
  def get_state() do
    Agent.get(__MODULE__, fn state -> state end)
  end

end

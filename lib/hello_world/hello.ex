alias Cizen.Effects.{Receive, Subscribe, Dispatch}
alias Cizen.{Event, Filter}

# Define events

defmodule HelloWorld.Events.MyNameIs do
  defstruct [:name]
end

defmodule HelloWorld.Events.Greeting do
  defstruct []

  use Cizen.Request
  defresponse Reply, :greeting_id do
    defstruct [:greeting_id, :message, :name]
  end
end

# Define Greeting automaton

defmodule HelloWorld.Greeting do
  use Cizen.Automaton

  defstruct []

  @impl true
  def spawn(id, _) do
    # Subscribe "MyNameIs" event
    perform id, %Subscribe{
      event_filter: Filter.new(
        fn %Event{body: %HelloWorld.Events.MyNameIs{}} -> true end
      )
    }

    # Subscribe "Greeting" event
    perform id, %Subscribe{
      event_filter: Filter.new(
        fn %Event{body: %HelloWorld.Events.Greeting{}} -> true end
      )
    }

    # State: :dont_know
    :dont_know
  end

  @impl true
  def yield(id, :dont_know) do
    # Wait for events
    event = perform id, %Receive{}

    case event.body do
      %HelloWorld.Events.MyNameIs{name: name} ->
        # Update state to :know with the name
        {:know, %{name: name}}
      %HelloWorld.Events.Greeting{} ->
        # Respond to "Greeting" event
        perform id, %Dispatch{
          body: %HelloWorld.Events.Greeting.Reply{
            greeting_id: event.id,
            message: "What is your name?",
            name: ""
          }
        }

        # No changes
        :dont_know
    end
  end

  @impl true
  def yield(id, {:know, %{name: name}}) do
    # Wait for events
    event = perform id, %Receive{}

    case event.body do
      %HelloWorld.Events.Greeting{} ->
        # Respond to "Greeting" event
        perform id, %Dispatch{
          body: %HelloWorld.Events.Greeting.Reply{
            greeting_id: event.id,
            message: "Hello #{name}",
            name: name
          }
        }

        # No changes
        {:know, %{name: name}}

      # Ignore "MyNameIs" event
      _ -> {:know, %{name: name}}
    end
  end
end

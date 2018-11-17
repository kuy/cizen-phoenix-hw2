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

    # Blank on init
    %{name: ""}
  end

  @impl true
  def yield(id, %{name: name}) do
    # Wait for events
    event = perform id, %Receive{}

    case event.body do
      %HelloWorld.Events.MyNameIs{name: name} ->
        # Update state with the given name
        %{name: name}
      %HelloWorld.Events.Greeting{} ->
        # Prepare a message based on the current state
        message = case name do
          "" -> "What is your name?"
          _ -> "Hello #{name}"
        end

        # Respond to "Greeting" event
        perform id, %Dispatch{
          body: %HelloWorld.Events.Greeting.Reply{
            greeting_id: event.id,
            message: message,
            name: name
          }
        }

        # No changes
        %{name: name}
    end
  end
end

alias Cizen.Effects.{Receive, Subscribe, Dispatch}
alias Cizen.{Event, Filter}

# Define Greeting event
defmodule HelloWorld.Greeting do
  defstruct []

  use Cizen.Request
  defresponse Reply, :greeting_id do
    defstruct [:greeting_id, :message]
  end
end

# Define Greeting Automaton
defmodule HelloWorld.GreetingAutomaton do
  use Cizen.Automaton

  defstruct []

  @impl true
  def spawn(id, _) do
    # Subscribe "Greeting" event
    perform id, %Subscribe{
      event_filter: Filter.new(
        fn %Event{body: %HelloWorld.Greeting{}} -> true end
      )
    }

    # No state in this automaton
    :loop
  end

  @impl true
  def yield(id, :loop) do
    # Wait for "Greeting" event
    event = perform id, %Receive{}

    # Respond to "Greeting" event
    perform id, %Dispatch{
      body: %HelloWorld.Greeting.Reply{
        greeting_id: event.id,
        message: "Hello Cizen"
      }
    }
    :loop
  end
end

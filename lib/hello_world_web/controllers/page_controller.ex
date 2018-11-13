alias Cizen.Effects.Request

defmodule HelloWorldWeb.PageController do
  use HelloWorldWeb, :controller

  # Required to use "handle" below
  use Cizen.Effectful

  def index(conn, _params) do
    # Interact with Cizen world using "handle"
    %{body: %{message: message}} = handle fn id ->
      perform id, %Request{body: %HelloWorld.Greeting{}}
    end

    render(conn, "index.html", message: message)
  end
end

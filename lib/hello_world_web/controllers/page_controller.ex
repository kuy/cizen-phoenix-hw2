alias Cizen.Effects.{Dispatch, Request}
alias HelloWorld.Events

defmodule HelloWorldWeb.PageController do
  use HelloWorldWeb, :controller

  # Required to use "handle" below
  use Cizen.Effectful

  def index(conn, _params) do
    # Ask a message
    %{body: %{message: message, name: name}} = handle fn id ->
      perform id, %Request{body: %Events.Greeting{}}
    end

    render(conn, "index.html", message: message, name: name, token: get_csrf_token())
  end

  def tell(conn, %{"name" => name}) do
    # Tell visitor's name
    handle fn id ->
      perform id, %Dispatch{body: %Events.MyNameIs{name: name}}
    end

    redirect(conn, to: "/")
  end
end

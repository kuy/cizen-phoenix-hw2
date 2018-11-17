defmodule HelloWorldWeb.Router do
  use HelloWorldWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HelloWorldWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/name", PageController, :tell
  end
end

defmodule GenserverAndTaskDemoWeb.Router do
  use GenserverAndTaskDemoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GenserverAndTaskDemoWeb do
    pipe_through :api
  end
end

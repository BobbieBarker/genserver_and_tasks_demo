defmodule GenserverAndTaskDemo.Foo.Impl do
  @moduledoc """
  This is where our application logic should be implemented. Implementing our
  logic here allows the code to remain seperated from how it is ran/orchestrated
  inside of the BEAM. Leaving it free to be moved around. This internal API
  is being used by a genserver today, but perhaps as the business needs change
  it becomes used as an oban worker tomorrow. By trying to write loosely coupled code
  that only interacts through interfaces we should be able to make it easier
  on our future selves to refactor our code for tomorrows requirements.
  """

  @type async_foo_res :: {:do_stuff_results, String.t()} | {:error, ErrorMessage.t()}
  @type foo_res :: {:ok, String.t()}

  # test command:
  # Phoenix.PubSub.broadcast(GenserverAndTaskDemo.PubSub, "foo_server:foo_events", {:foo_request, "happy path"})
  @spec do_stuff(String.t()) :: async_foo_res
  def do_stuff("happy path") do
    {:do_stuff_results, "great results"}
  end

  # test command:
  # Phoenix.PubSub.broadcast(GenserverAndTaskDemo.PubSub, "foo_server:foo_events", {:bar_request, "timeout path"})
  def do_stuff("timeout path") do
    Process.sleep(:timer.seconds(30))

    {:do_stuff_results, "message dies in the void."}
  end

  def do_stuff("error path") do
    {:error, ErrorMessage.bad_request("oh no big problemos.")}
  end

  @spec do_direct_stuff(String.t()) :: foo_res
  def do_direct_stuff("happy path") do
    {:ok, "great sync results"}
  end

  def do_direct_stuff("timeout path") do
    Process.sleep(:timer.seconds(30))

    {:ok, "doesn't matter because it dies in the void"}
  end
end

defmodule GenserverAndTaskDemo.Foo do
  @moduledoc """
  This module implements our public API to the rest of our aplication for interacting
  with our Foo component. This pattern is inspired by Dave Thomas.
  """

  alias GenserverAndTaskDemo.Foo.Server

  @request_timeout :timer.seconds(5)

  defdelegate task_supervisor_name(), to: Server
  defdelegate start_link(opts), to: Server
  defdelegate child_spec(opts), to: Server

  # GenserverAndTaskDemo.Foo.foo_request("happy path")
  # GenserverAndTaskDemo.Foo.foo_request("timeout path")
  def foo_request(payload) do
    GenServer.call(
      Server,
      {:direct_foo_request, payload},
      @request_timeout
    )
  catch
    :exit, {:timeout, _} ->
      "A request timed out"
      |> ErrorMessage.gateway_timeout()
      |> then(&{:error, &1})
  end
end

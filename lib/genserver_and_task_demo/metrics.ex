defmodule GenserverAndTaskDemo.Metrics do
  @moduledoc """
  I setup this module to help illustrate how we might want to instruement our
  GenServer.
  """

  @spec incr_task_timeout(module()) :: :ok
  def incr_task_timeout(module_name) do
    :telemetry.execute(
      [:foo_app, :foo, :task_timeout_counter],
      %{count: 1},
      %{module: module_name}
    )
  end
end

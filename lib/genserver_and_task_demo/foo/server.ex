defmodule GenserverAndTaskDemo.Foo.Server do
  @moduledoc """
  This is were we implement the GenServer callbacks and other concerns
  around managing and monitoring processes and performance.
  """

  alias GenserverAndTaskDemo.Metrics
  alias GenserverAndTaskDemo.Foo.Impl

  use GenServer
  require Logger

  @task_timeout :timer.seconds(10)
  @fast_task_timeout :timer.seconds(1)
  @task_supervisor_name :foo_task_supervisor

  def task_supervisor_name, do: @task_supervisor_name

  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @impl GenServer
  def init(state \\ %{}) do
    _ = Phoenix.PubSub.subscribe(
      GenserverAndTaskDemo.PubSub,
      "foo_server:foo_events"
    )

    {:ok, state}
  end

  @impl GenServer
  def handle_info({_pid, {:do_stuff_results, results}}, state) do
    _ = Phoenix.PubSub.broadcast(
      GenserverAndTaskDemo.PubSub,
      "do_foo_results",
      {"bar", %{type: :result, payload: results}}
    )

    {:noreply, state}
  end

  def handle_info({:foo_request, payload}, genserver_state) do
    %Task{pid: pid} = Task.Supervisor.async_nolink(
      @task_supervisor_name,
      Impl,
      :do_stuff,
      [payload]
    )

    Process.send_after(self(), {:timeout, pid}, @task_timeout)
    {:noreply, genserver_state}
  end

  def handle_info({:bar_request, payload}, genserver_state) do
    %Task{pid: pid} = Task.Supervisor.async_nolink(
      @task_supervisor_name,
      Impl,
      :do_stuff,
      [payload]
    )

    Process.send_after(self(), {:timeout, pid}, @fast_task_timeout)
    {:noreply, genserver_state}
  end

  def handle_info({:timeout, task_pid}, genserver_state) do
    with :ok <- Task.Supervisor.terminate_child(
      @task_supervisor_name,
      task_pid
    ) do
      "A process failed to complete its task before it timed out"
      |> ErrorMessage.gateway_timeout()
      |> tap(fn _ -> Metrics.incr_task_timeout(__MODULE__) end)
      |> Logger.debug()
    end


    {:noreply, genserver_state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _}, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:direct_foo_request, payload}, _from, state) do
    {:reply, Impl.do_direct_stuff(payload), state}
  end
end

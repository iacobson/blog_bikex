defmodule Mock.Server do
  @moduledoc """
  Generic mock server that keeps track of external services responses.
  Each external service initialize one of those servers.
  """
  use GenServer

  # API

  def start_link(responses) do
    GenServer.start_link(__MODULE__, responses)
  end

  def request(pid, type) do
    GenServer.call(pid, {:request, type})
  end

  def get_last_response(pid) do
    GenServer.call(pid, :get_last_response)
  end

  # CALLBACKS

  def init(responses) do
    {:ok, %{last_response: :not_called, responses: responses}}
  end

  def handle_call({:request, type}, _from, state) do
    case state[:responses][type] do
      [] ->
        {:stop, :cannot_handle_more_requests, state}

      [response | responses] ->
        new_state =
          state
          |> put_in([:last_response], response)
          |> put_in([:responses, type], responses)

        {:reply, response, new_state}
    end
  end

  def handle_call(:get_last_response, _from, state) do
    {:reply, state[:last_response], state}
  end
end

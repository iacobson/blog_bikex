defmodule BikexTest do
  use ExUnit.Case
  use ExUnitProperties
  alias Mock.{Server, BrakesSupplier}

  @supplier_order_responses [{:ok, :ordered}, {:error, :out_of_stock}, {:error, :no_response}]

  property "check bike ordering saga" do
    check all order_brakes_responses <- generate_responses_list(@supplier_order_responses),
              max_runs: 100_00 do
      {:ok, brakes_pid} = Server.start_link(%{order: order_brakes_responses})
      pids = {brakes_pid}

      pids
      |> Bikex.order_bike()
      |> check_result(pids)
    end
  end

  defp check_result(
         {:ok, _result, %{brakes: %BrakesSupplier{brakes_order: brakes_order, state: state}}},
         {brakes_pid}
       ) do
    assert brakes_order == brakes_pid
    assert state == :ordered
    assert Server.get_last_response(brakes_pid) == {:ok, :ordered}
  end

  defp check_result({:error, {:brakes, :no_response}}, {brakes_pid}) do
    assert Server.get_last_response(brakes_pid) == {:error, :no_response}
  end

  defp check_result({:error, {:brakes, :out_of_stock}}, {brakes_pid}) do
    assert Server.get_last_response(brakes_pid) == {:error, :out_of_stock}
  end

  defp generate_responses_list(responses) do
    StreamData.member_of(responses)
    |> StreamData.list_of(length: 3)
  end
end

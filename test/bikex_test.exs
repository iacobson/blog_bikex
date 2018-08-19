defmodule BikexTest do
  use ExUnit.Case
  use ExUnitProperties
  alias Mock.{Server, BrakesSupplier, TyresSupplier}

  @supplier_order_responses [{:ok, :ordered}, {:error, :out_of_stock}, {:error, :no_response}]
  @supplier_cancel_responses [{:ok, :canceled}, {:error, :no_response}]

  property "check bike ordering saga" do
    check all order_brakes_responses <- generate_responses_list(@supplier_order_responses),
              cancel_brakes_responses <- generate_responses_list(@supplier_cancel_responses),
              order_tyres_responses <- generate_responses_list(@supplier_order_responses),
              cancel_tyres_responses <- generate_responses_list(@supplier_cancel_responses),
              max_runs: 100_00 do
      {:ok, brakes_pid} =
        Server.start_link(%{order: order_brakes_responses, cancel: cancel_brakes_responses})

      {:ok, tyres_pid} =
        Server.start_link(%{order: order_tyres_responses, cancel: cancel_tyres_responses})

      pids = [brakes_pid, tyres_pid]

      pids
      |> Bikex.order_bike()
      |> check_result(pids)
    end
  end

  defp check_result(
         {:ok, _result,
          %{
            brakes: %BrakesSupplier{brakes_order: brakes_order, state: :ordered},
            tyres: %TyresSupplier{tyres_order: tyres_order, state: :ordered}
          }},
         [brakes_pid, tyres_pid]
       ) do
    assert brakes_order == brakes_pid
    assert tyres_order == tyres_pid
  end

  defp check_result({:error, _error}, pids) do
    for pid <- pids do
      assert Server.get_last_response(pid) in [
               {:error, :no_response},
               {:error, :out_of_stock},
               {:ok, :canceled}
             ]
    end
  end

  defp generate_responses_list(responses) do
    responses
    |> StreamData.member_of()
    |> StreamData.list_of(length: 3)
  end
end

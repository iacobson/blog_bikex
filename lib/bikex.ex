defmodule Bikex do
  require Logger

  alias Mock.{BrakesSupplier, TyresSupplier}

  def order_bike([brakes_pid, tyres_pid]) do
    Sage.new()
    |> Sage.run_async(:brakes, &brakes_transaction/2, &brakes_compensation/4)
    |> Sage.run_async(:tyres, &tyres_transaction/2, &tyres_compensation/4)
    |> Sage.execute(%{bike_order: self(), brakes_pid: brakes_pid, tyres_pid: tyres_pid})
  end

  defp brakes_transaction(_effects_so_far, %{brakes_pid: brakes_pid}) do
    BrakesSupplier.order(brakes_pid)
  end

  defp brakes_compensation(
         %BrakesSupplier{state: :ordered, brakes_order: brakes_pid},
         _effects_so_far,
         _error,
         _attrs
       ) do
    case BrakesSupplier.cancel(brakes_pid) do
      {:ok, _canceled_brakes_order} ->
        :abort

      {:error, {:brakes, :no_response}} ->
        Logger.error(
          "Cancel brakes order failure, for order: #{inspect(brakes_pid)}. Manual action required."
        )

        :abort
    end
  end

  defp brakes_compensation(_effect_to_compensate, _effects_so_far, _error, _attrs) do
    :abort
  end

  defp tyres_transaction(_effects_so_far, %{tyres_pid: tyres_pid}) do
    TyresSupplier.order(tyres_pid)
  end

  defp tyres_compensation(
         %TyresSupplier{state: :ordered, tyres_order: tyres_pid},
         _effects_so_far,
         _error,
         _attrs
       ) do
    case TyresSupplier.cancel(tyres_pid) do
      {:ok, _canceled_tyres_order} ->
        :abort

      {:error, {:tyres, :no_response}} ->
        Logger.error(
          "Cancel tyres order failure, for order: #{inspect(tyres_pid)}. Manual action required."
        )

        :abort
    end
  end

  defp tyres_compensation(_effect_to_compensate, _effects_so_far, _error, _attrs) do
    :abort
  end
end

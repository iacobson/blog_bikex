defmodule Bikex do
  require Logger

  alias Mock.{BrakesSupplier}

  def order_bike({brakes_pid}) do
    Sage.new()
    # |> Sage.run(:catch, &not_used/2, &catch_failed_retries/4)
    |> Sage.run(:brakes, &brakes_transaction/2, &brakes_compensation/4)
    |> Sage.execute(%{bike_order: self(), brakes_pid: brakes_pid})
  end

  # defp not_used(_, _) do
  # {:ok, %{}}
  # end

  # defp catch_failed_retries(
  # effect_to_comp,
  # effects_so_far,
  # {failed_stage_name, {_provider, :no_response}},
  # attrs
  # ) do
  # Logger.error(
  # "Retry failed for stage: #{inspect(failed_stage_name)}. Manual action may be required. Order: #{
  # inspect(attrs.bike_order)
  # }. Effects: #{inspect(effects_so_far)}"
  # )

  # IO.inspect(effect_to_comp, label: "EFFECTS TO COMP")
  # IO.inspect(effects_so_far, label: "EFFECTS SO FAR")
  # IO.inspect(failed_stage_name, label: "FAILED STAGE NAME")
  # IO.inspect(attrs, label: "ATTRS")
  # :abort
  # end

  # defp catch_failed_retries(_effects_to_comp, _effects_so_far, _error, _attrs) do
  # :abort
  # end

  defp brakes_transaction(_effects_so_far, %{brakes_pid: brakes_pid}) do
    BrakesSupplier.order(brakes_pid)
  end

  defp brakes_compensation(
         _effect_to_compensate,
         _effects_so_far,
         {:brakes, {:brakes, :no_response}},
         _attrs
       ) do
    {:retry, retry_limit: 2}
  end

  defp brakes_compensation(_effect_to_compensate, _effects_so_far, _error, _attrs) do
    :abort
  end
end

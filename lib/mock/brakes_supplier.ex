defmodule Mock.BrakesSupplier do
  defstruct brakes_order: nil, state: nil

  alias __MODULE__

  def order(pid) do
    case Mock.Server.request(pid, :order) do
      {:ok, :ordered} -> {:ok, %BrakesSupplier{brakes_order: pid, state: :ordered}}
      {:error, :out_of_stock} -> {:error, {:brakes, :out_of_stock}}
      {:error, :no_response} -> {:error, {:brakes, :no_response}}
    end
  end

  def cancel(pid) do
    case Mock.Server.request(pid, :cancel) do
      {:ok, :canceled} -> {:ok, %BrakesSupplier{brakes_order: pid, state: :cancelled}}
      {:error, :no_response} -> {:error, {:brakes, :no_response}}
    end
  end
end

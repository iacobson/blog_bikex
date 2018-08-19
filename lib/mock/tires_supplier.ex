defmodule Mock.TyresSupplier do
  defstruct tyres_order: nil, state: nil

  alias __MODULE__

  def order(pid) do
    case Mock.Server.request(pid, :order) do
      {:ok, :ordered} -> {:ok, %TyresSupplier{tyres_order: pid, state: :ordered}}
      {:error, :out_of_stock} -> {:error, {:tyres, :out_of_stock}}
      {:error, :no_response} -> {:error, {:tyres, :no_response}}
    end
  end

  def cancel(pid) do
    case Mock.Server.request(pid, :cancel) do
      {:ok, :canceled} -> {:ok, %TyresSupplier{tyres_order: pid, state: :cancelled}}
      {:error, :no_response} -> {:error, {:tyres, :no_response}}
    end
  end
end

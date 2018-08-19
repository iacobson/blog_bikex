defmodule Mock.PaymentProvider do
  defstruct payment_order: nil, state: nil

  alias __MODULE__

  def pay(pid) do
    case Mock.Server.request(pid, :pay) do
      {:ok, :paid} -> {:ok, %PaymentProvider{payment_order: pid, state: :paid}}
      {:error, :no_funds} -> {:error, {:payment, :no_funds}}
      {:error, :no_response} -> {:error, {:payment, :no_response}}
    end
  end
end

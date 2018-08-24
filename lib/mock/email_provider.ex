defmodule Mock.EmailProvider do
  defstruct ref: nil, state: nil

  alias __MODULE__

  def send(pid) do
    case Mock.Server.request(pid, :send) do
      {:ok, :sent} -> {:ok, %EmailProvider{ref: pid, state: :sent}}
      {:error, :failed} -> {:error, {:email, :failed}}
      {:error, :no_response} -> {:error, {:email, :no_response}}
    end
  end
end

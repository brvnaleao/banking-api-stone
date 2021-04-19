defmodule BankingApi.Notifications.Email do
  @moduledoc """
  Email Notification Module
  """
  @spec send_email(:transfer | :withdrawal, any) :: :ok
  def send_email(:withdrawal, struct) do
    IO.puts(
      "The withdrawal with a value of #{transform_into_money_string(struct)} was successfully carried out."
    )
  end

  def send_email(:transfer, struct) do
    IO.puts(
      "The transfer with a value of #{transform_into_money_string(struct)} was successfully carried out."
    )
  end

  defp transform_into_money_string(struct) do
    Money.new(struct.balance, :USD)
    |> Money.to_string()
  end
end

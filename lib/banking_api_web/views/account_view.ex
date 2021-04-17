defmodule BankingApiWeb.AccountView do
  def render("update_balance.json", %{account: account}) do
    money =
      Money.new(account.balance, :USD)
      |> Money.to_string()

    %{
      description: "Your actual balance is #{money}"
    }
  end

  def render("transfer_balance.json", %{account: account}) do
    money =
      Money.new(account.balance, :USD)
      |> Money.to_string()

    %{
      description: "Operation complete sucessifully. Your actual balance is #{money}"
    }
  end
end

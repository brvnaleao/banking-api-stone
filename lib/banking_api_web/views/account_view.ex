defmodule BankingApiWeb.AccountView do
  def render("update_balance.json", %{account: account}) do
    %{
      balance: "Your acctual balance is #{account.balance}"
    }
  end

  def render("transfer_balance.json", %{account: account}) do
    %{
      balance: "Operation complete sucessifully. Your acctual balance is #{account.balance}"
    }
  end
end

defmodule BankingApiWeb.UserView do
  def render("transform_into_map.json", %{user: user}) do
    %{
      description: %{
      id: user.insert_user.id,
      name: user.insert_user.name,
      email: user.insert_user.email,
      cpf: user.insert_user.cpf,
      account_id: user.insert_account.id,
      balance: "Your actual balance is $1000.00"
    }
  }
  end
end

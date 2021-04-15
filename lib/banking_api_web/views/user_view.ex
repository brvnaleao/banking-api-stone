defmodule BankingApiWeb.UserView do
  def render("transform_into_map.json", %{user: user}) do
    %{
      id: user.insert_user.id,
      name: user.insert_user.name,
      email: user.insert_user.email,
      cpf: user.insert_user.cpf,
      account_id: user.insert_account.id
    }
  end
end

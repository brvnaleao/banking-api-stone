defmodule BankingApi.Users do
  alias BankingApi.Users.Schemas.User
  alias BankingApi.Accounts.Schemas.Account
  alias BankingApi.Repo

  def create_user_and_account(params) do
    user_chageset =
      params
      |> User.changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:insert_user, user_chageset)
    |> Ecto.Multi.insert(:insert_account, fn %{insert_user: user} ->
      Account.changeset(%{user_id: user.id})
      |> Ecto.Changeset.put_assoc(:user, user)
    end)
    |> Repo.transaction()
  end
end

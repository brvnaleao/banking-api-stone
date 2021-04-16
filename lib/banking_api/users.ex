defmodule BankingApi.Users do
  @moduledoc """
  User's business logic
  """
  alias BankingApi.Accounts.Schemas.Account
  alias BankingApi.Accounts.Schemas.Transaction
  alias BankingApi.Users.Schemas.User

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
    |> Ecto.Multi.insert(:save_transact, fn %{insert_account: account} ->
      Transaction.changeset(%{account_id: account.id, external: true, value: 1000})
      |> Ecto.Changeset.put_assoc(:account, account)
    end)
    |> Repo.transaction()
  end
end

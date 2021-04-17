defmodule BankingApi.Accounts do
  @moduledoc """
  Account's business logic
  """

  alias BankingApi.Accounts.Inputs.Transfer
  alias BankingApi.Accounts.Inputs.Withdrawal
  alias BankingApi.Accounts.Schemas.Account
  alias BankingApi.Accounts.Schemas.Transaction

  alias BankingApi.Repo

  import Ecto.Query, only: [from: 2]

  defp update_balance(arguments) do
    Repo.transaction(fn ->

      query = from(a in Account, where: a.id == ^arguments.id, lock: "FOR UPDATE")

      with %Account{} = account <- Repo.one(query),
           {:ok, struct} <- update_values(account, account.balance - arguments.withdrawal),
           {:ok, _} <- save_transaction(-arguments.withdrawal, account.id, true) do
        struct
      else
        nil ->
          Repo.rollback(:invalid_account)
        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  defp save_transaction(value, account_id, external_or_not) do
    Repo.insert(%Transaction{
      value: value,
      account_id: account_id,
      external: external_or_not
    })
  end

  defp save_transaction(value, account_id, external_or_not, transaction_id) do
    Repo.insert(%Transaction{
      value: value,
      account_id: account_id,
      external: external_or_not,
      transaction_id: transaction_id
    })
  end

  defp update_values(_changeset, value) when value < 0, do: {:error, :balance_error}

  defp update_values(changeset, new_value) do
    changeset
    |> Ecto.Changeset.change(balance: new_value)
    |> Repo.update()
  end

  defp validate_inputs(params, module) do
    params
    |> module.changeset()
    |> case do
      %{valid?: true} = changeset -> {:ok, Ecto.Changeset.apply_changes(changeset)}
      changeset -> {:error, changeset}
    end
  end

  defp generate_UUID do
    {:uuid, Ecto.UUID.generate()}
  end

  defp create_transfer(params) do

    Repo.transaction(fn ->

      query = from(a in Account, where: a.id == ^params.origin, lock: "FOR UPDATE")
      second_query = from(a in Account, where: a.id == ^params.destiny, lock: "FOR UPDATE")
      value = params.value

      with %Account{} = origin_account <- Repo.one(query),
           %Account{} = destiny_account <- Repo.one(second_query),
           {:ok, new_value_origin} <- {:ok, origin_account.balance - value},
           {:ok, new_value_destiny} <- {:ok, destiny_account.balance + value},
           {:uuid, transaction_id} <- generate_UUID(),
           {:ok, struct} <- update_values(origin_account, new_value_origin),
           {:ok, _} <- update_values(destiny_account, new_value_destiny),
           {:ok, _} <- save_transaction(-value, origin_account.id, false, transaction_id),
           {:ok, _} <- save_transaction(value, destiny_account.id, false, transaction_id) do
        struct
      else
        nil ->
          Repo.rollback(:invalid_account)
        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  def transfer_between_accounts(params) do
    with {:ok, input} <- validate_inputs(params, Transfer),
         {:ok, transfer} <- create_transfer(input) do
      {:ok, transfer}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def withdraw(params) do
    with {:ok, struct} <- validate_inputs(params, Withdrawal),
         {:ok, struct} <- update_balance(struct) do
      {:ok, struct}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def fetch(account_id) do
    from(a in Account, where: a.id == ^account_id, select: a.balance)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}
      value ->
        value_string = value |> Money.new(:USD) |> Money.to_string()
        {:ok, value_string}
    end
  end
end

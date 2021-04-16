defmodule BankingApi.Accounts do
  alias BankingApi.Accounts.Schemas.Account
  alias BankingApi.Accounts.Schemas.Transaction
  alias BankingApi.Accounts.Inputs.Transfer
  alias BankingApi.Accounts.Inputs.Withdrawn

  alias BankingApi.Repo

  import Ecto.Query, only: [from: 2]

  defp update_balance(arguments) do
    Repo.transaction(fn ->
      query = from(a in Account, where: a.id == ^arguments.id, lock: "FOR UPDATE")

      account = Repo.one(query)

      if(account !== nil) do
        withdrawn = arguments.withdrawn
        new_value = account.balance - withdrawn

        with {:ok, struct} <- update_values(account, new_value),
             {:ok, _} <- save_transaction(-withdrawn, account.id, true) do
          struct
        else
          {:error, error} -> Repo.rollback(error)
        end
      else
        Repo.rollback(:invalid_account)
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

  defp update_values(_changeset, value) when value <= 0, do: {:error, :balance_error}

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

  defp create_transfer(changeset) do
    Repo.transaction(fn ->
      first_query = from(a in Account, where: a.id == ^changeset.origin, lock: "FOR UPDATE")
      second_query = from(a in Account, where: a.id == ^changeset.destiny, lock: "FOR UPDATE")

      origin_account = Repo.one(first_query)
      destiny_account = Repo.one(second_query)

      if(
        origin_account == nil or
          destiny_account == nil
      ) do
        Repo.rollback(:invalid_accounts)
      else
        value = changeset.value

        new_value_origin = origin_account.balance - value
        new_value_destiny = destiny_account.balance + value

        with {:ok, struct} <- update_values(origin_account, new_value_origin),
             {:ok, _} <- update_values(destiny_account, new_value_destiny),
             {:ok, _} <- save_transaction(-value, origin_account.id, false),
             {:ok, _} <- save_transaction(value, destiny_account.id, false) do
          struct
        else
          {:error, error} ->
            Repo.rollback(error)
        end
      end
    end)
  end

  def transfer_between_accounts(params) do
    with {:ok, struct} <- validate_inputs(params, Transfer),
         {:ok, struct} <- create_transfer(struct) do
      {:ok, struct}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def withdrawn(params) do
    with {:ok, struct} <- validate_inputs(params, Withdrawn),
         {:ok, struct} <- update_balance(struct) do
      {:ok, struct}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def fetch(account_id) do
    query = from(a in Account, where: a.id == ^account_id, select: a.balance)
    balance = Repo.one(query)

    case balance do
      nil ->
        {:error, :not_found}

      value ->
        money = Money.new(value, :USD)
        {:ok, Money.to_string(money)}
    end
  end
end

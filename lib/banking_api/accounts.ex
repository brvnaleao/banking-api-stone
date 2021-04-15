defmodule BankingApi.Accounts do
  alias BankingApi.Accounts.Schemas.Account
  alias BankingApi.Accounts.Schemas.Transaction
  alias BankingApi.Accounts.Inputs.Transference
  alias BankingApi.Accounts.Inputs.Withdrawal

  alias BankingApi.Repo

  import Ecto.Query, only: [from: 2]

  def update_balance(changeset) do
    query = from(a in Account, where: a.id == ^changeset.id, lock: "FOR UPDATE")
    IO.inspect(query)

    result = Repo.all(query)

    if(result !== nil and result !== []) do
      [account | _] = result
      withdrawal = changeset.withdrawal
      new_value = account.balance - withdrawal

      with {:ok, struct} <- update_values(account, new_value),
           {:ok, _} <- save_transaction(-withdrawal, account.id, true) do
        {:ok, struct}
      else
        {:error, error} -> {:error, error}
      end
    else
      {:error, :invalid_account}
    end
  end

  def save_transaction(value, account_id, external_or_not) do
    Repo.insert(%Transaction{
      value: value,
      account_id: account_id,
      external: external_or_not
    })
  end

  defp update_values(changeset, new_value) do
    cond do
      new_value <= 0 ->
        {:error, :balance_error}

      true ->
        changeset
        |> Ecto.Changeset.change(balance: new_value)
        |> Repo.update()
    end
  end

  def validate_inputs(params, module) do
    params
    |> module.changeset()
  end

  def create_transference(changeset) do
    first_query = from(a in Account, where: a.id == ^changeset.origin, lock: "FOR UPDATE")
    second_query = from(a in Account, where: a.id == ^changeset.destiny, lock: "FOR UPDATE")

    result_first_query = Repo.all(first_query)
    result_second_query = Repo.all(second_query)

    if(
      result_first_query == nil or
        result_second_query == nil or
        result_second_query == [] or
        result_first_query == []
    ) do
      {:error, :invalid_accounts}
    else
      Repo.transaction(fn ->
        value = changeset.value

        [origin_account | _] = result_first_query
        [destiny_account | _] = result_second_query

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
      end)
    end
  end

  def transference_between_accounts(params) do
    with %{valid?: true} = changeset <- validate_inputs(params, Transference),
         {:ok, struct} <- create_transference(changeset.changes) do
      {:ok, struct}
    else
      %{valid?: false} = changeset ->
        {:error, changeset}

      {:error, error} ->
        {:error, error}
    end
  end

  def withdrawal(params) do
    with %{valid?: true} = changeset <- validate_inputs(params, Withdrawal),
         {:ok, struct} <- update_balance(changeset.changes) do
      {:ok, struct}
    else
      %{valid?: false} = changeset ->
        {:error, changeset}

      {:error, error} ->
        {:error, error}
    end
  end

  def fetch(account_id) do
    IO.inspect("Fetch account by id: #{inspect(account_id)}")

    query = from(a in Account, where: a.id == ^account_id, select: a.balance)
    balance = Repo.all(query)

    case balance do
      nil ->
        {:error, :not_found}

      [value | _] ->
        money = Money.new(value, :USD)
        {:ok, Money.to_string(money)}
    end
  end
end

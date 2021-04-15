defmodule BankingApiWeb.AccountController do
  use BankingApiWeb, :controller
  alias BankingApi.Accounts

  def show(conn, %{"id" => account_id}) do
    with {:uuid, {:ok, _}} <- {:uuid, Ecto.UUID.cast(account_id)},
         {:ok, value} <- Accounts.fetch(account_id) do
      send_json(conn, 200, %{description: "Your actual balance is #{value}"})
    else
      {:uuid, :error} ->
        send_json(conn, 400, %{type: "bad_input", description: "Invalid Id"})

      {:error, :not_found} ->
        send_json(conn, 404, %{type: "not_found", description: "Account not found"})
    end
  end

  def withdrawn(conn, %{"id" => account_id} = params) when is_map(params) do
    with {:uuid, {:ok, _}} <- {:uuid, Ecto.UUID.cast(account_id)},
         {:ok, struct} <- Accounts.withdrawn(params) do
      render_json(conn, struct, "update_balance.json")
    else
      {:uuid, :error} ->
        send_json(conn, 400, %{type: "bad_input", description: "Invalid Id"})

      {:error, :balance_error} ->
        send_json(conn, 400, %{
          type: "negative_value",
          description: "Your balance cannot be negative"
        })

      {:error, :invalid_account} ->
        send_json(conn, 404, %{type: "not_found", description: "Account not found"})

      {:error, changeset} ->
        send_json(conn, 400, transform_into_map(changeset.errors))
    end
  end

  def tranfer_between_accounts(
        conn,
        %{"origin" => origin, "destiny" => destiny} = params
      )
      when is_map(params) do
    with {:uuid, {:ok, _}} <- {:uuid, Ecto.UUID.cast(origin)},
         {:uuid, {:ok, _}} <- {:uuid, Ecto.UUID.cast(destiny)},
         {:ok, struct} <- Accounts.transfer_between_accounts(params) do
      render_json(conn, struct, "transfer_balance.json")
    else
      {:uuid, :error} ->
        send_json(conn, 400, %{type: "bad_input", description: "Invalid Id"})

      {:error, :balance_error} ->
        send_json(conn, 400, %{
          type: "negative_value",
          description: "Your balance cannot be negative"
        })

      {:error, :invalid_accounts} ->
        send_json(conn, 404, %{type: "not_found", description: "Account not found"})

      {:error, :wrong_input} ->
        send_json(conn, 404, %{type: "wrong_input", description: "You sent a invalid value"})

      {:error, %Ecto.Changeset{errors: errors}} ->
        msg = %{
          type: "bad_input",
          description: "Invalid input",
          details: transform_into_map(errors)
        }

        send_json(conn, 400, msg)
    end
  end

  defp render_json(conn, account, template) do
    conn
    |> put_status(:created)
    |> render(template, account: account)
  end

  defp send_json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  defp transform_into_map(errors) do
    errors
    |> Enum.map(fn {key, {message, _opts}} -> {key, message} end)
    |> Map.new()
  end
end

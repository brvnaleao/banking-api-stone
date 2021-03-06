defmodule BankingApiWeb.AccountController do
  use BankingApiWeb, :controller
  alias BankingApi.Accounts
  alias BankingApi.Notifications.Email

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

  def withdraw(conn, params) when is_map(params) do
    case Accounts.withdraw(params) do
      {:ok, struct} ->
        Email.send_email(:withdrawal, struct)
        render_json(conn, struct, "update_balance.json")

      {:error, :balance_error} ->
        send_json(conn, 400, %{
          type: "negative_value",
          description: "Your balance cannot be negative"
        })

      {:error, :invalid_account} ->
        send_json(conn, 404, %{type: "not_found", description: "Account not found"})

      {:error, %Ecto.Changeset{errors: errors}} ->
        send_json(conn, 400, get_error_template(errors))
    end
  end

  defp get_error_template(errors) do
    %{
      type: "bad_input",
      description: transform_into_map(errors)
    }
  end

  def tranfer_between_accounts(conn, params) when is_map(params) do
    case Accounts.transfer_between_accounts(params) do
      {:ok, struct} ->
        Email.send_email(:transfer, struct)
        render_json(conn, struct, "transfer_balance.json")

      {:error, :balance_error} ->
        send_json(conn, 400, %{
          type: "negative_value",
          description: "Your balance cannot be negative"
        })

      {:error, :invalid_account} ->
        send_json(conn, 404, %{type: "not_found", description: "Account not found"})

      {:error, :wrong_input} ->
        send_json(conn, 404, %{type: "wrong_input", description: "You sent a invalid value"})

      {:error, %Ecto.Changeset{errors: errors}} ->
        send_json(conn, 400, get_error_template(errors))
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

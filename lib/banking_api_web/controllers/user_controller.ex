defmodule BankingApiWeb.UserController do
  use BankingApiWeb, :controller

  alias BankingApi.Users

  def create(conn, params) when is_map(params) do

    case Users.create_user_and_account(params) do
      {:ok, user} -> send_json(conn, user)
      {:error, _, changeset, _} ->
        set_error(conn, 400, get_error_template(changeset.errors))
    end
  end

  defp get_error_template(errors) do
    %{
      type: "bad_input",
      description: transform_into_map(errors)
    }
  end

  defp send_json(conn, user) do
    conn
    |> put_status(:created)
    |> put_resp_header("content-type", "application/json")
    |> render("transform_into_map.json", user: user)
  end

  defp transform_into_map(errors) do
    errors
    |> Enum.map(fn {key, {message, _opts}} -> {key, message} end)
    |> Map.new()
  end

  defp set_error(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end

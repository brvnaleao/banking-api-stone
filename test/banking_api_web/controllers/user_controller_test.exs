defmodule BankingApiWeb.UserControllerTest do
  use BankingApiWeb.ConnCase, async: true

  alias BankingApi.Accounts.Schemas.Account
  alias BankingApi.Repo

  # Triple AAA: Arrange, Act and Assert

  describe "POST /api/users" do
    test "return a successs status", ctx do
      input = %{
        "cpf" => "15034815738",
        "email" => "ajos9x6j692@do69has0sds.com",
        "name" => "eu"
      }

      assert ctx.conn
             |> post("/api/users", input)
             |> json_response(201)
    end


  end
end

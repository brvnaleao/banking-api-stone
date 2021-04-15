defmodule BankingApiWeb.AccountControllerTest do
  use BankingApiWeb.ConnCase, async: true

  alias BankingApi.Accounts.Schemas.Account
  alias BankingApi.Users.Schemas.User

  alias BankingApi.Repo

  # Triple AAA: Arrange, Act and Assert

  describe "GET /api/account/:id" do
    test "return a successs status", ctx do
      user =
        Repo.insert!(%User{
          name: "name",
          email: "#{Ecto.UUID.generate()}@email.com",
          cpf:
            Ecto.UUID.generate()
            |> String.slice(0..10)
        })

      account =
        Repo.insert!(%Account{
          user_id: user.id
        })

      assert %{"description" => description} =
               ctx.conn
               |> get("/api/account/#{account.id}")
               |> json_response(200)
    end
  end

  describe "post /account/withdraw" do
    test "return a successs status", ctx do
      user =
        Repo.insert!(%User{
          name: "name",
          email: "#{Ecto.UUID.generate()}@email.com",
          cpf:
            Ecto.UUID.generate()
            |> String.slice(0..10)
        })

      account =
        Repo.insert!(%Account{
          user_id: user.id
        })

      input = %{
        "id" => account.id,
        "withdraw" => "100"
      }

      assert ctx.conn
             |> post("/api/account/withdraw", input)
             |> json_response(201)
    end
  end

  describe "post /account/transfer" do
    test "return a successs status", ctx do
      user =
        Repo.insert!(%User{
          name: "name",
          email: "#{Ecto.UUID.generate()}@email.com",
          cpf:
            Ecto.UUID.generate()
            |> String.slice(0..10)
        })

      account =
        Repo.insert!(%Account{
          user_id: user.id
        })

      second_user =
        Repo.insert!(%User{
          name: "name",
          email: "#{Ecto.UUID.generate()}@email.com",
          cpf:
            Ecto.UUID.generate()
            |> String.slice(0..10)
        })

      second_account =
        Repo.insert!(%Account{
          user_id: user.id
        })

      input = %{
        "origin" => account.id,
        "destiny" => second_account.id,
        "value" => "100"
      }

      assert ctx.conn
             |> post("/api/account/transfer", input)
             |> json_response(201)
    end
  end
end

defmodule BankingApiWeb.Router do
  use BankingApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankingApiWeb do
    pipe_through :api

    get "/account/:id", AccountController, :show
    # get "/accounts", AccountController, :list

    post "/account/withdrawn", AccountController, :withdrawn
    post "/account/transfer", AccountController, :tranfer_between_accounts
    post "/users", UserController, :create
  end
end

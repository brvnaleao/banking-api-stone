defmodule BankingApi.Users.Schemas.User do
  @moduledoc """
  User's Schema Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias BankingApi.Accounts.Schemas.Account
  @derive {Jason.Encoder, except: [:__meta__]}

  @required_fields [:name, :email, :cpf]
  @email_regex ~r/^[A-Za-z0-9\._%+\-+']+@[A-Za-z0-9\.\-]+\.[A-Za-z]{2,4}$/

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :name, :string
    field :email, :string
    field :cpf, :string

    has_one(:account, Account)

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 2)
    |> validate_length(:cpf, is: 11)
    |> validate_format(:email, @email_regex)
    |> unique_constraint(:email)
    |> unique_constraint(:cpf)
  end
end

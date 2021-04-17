defmodule BankingApi.Accounts.Inputs.Withdrawal do
  @moduledoc """
  Input validation for withdrawal
  """
  use Ecto.Schema

  import Ecto.Changeset

  @required [:id, :withdrawal]

  @primary_key false
  embedded_schema do
    field :id, Ecto.UUID
    field :withdrawal, :integer
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_number(:withdrawal, greater_than: 0)
  end
end

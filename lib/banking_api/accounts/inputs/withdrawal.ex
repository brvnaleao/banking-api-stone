defmodule BankingApi.Accounts.Inputs.Withdrawal do
  @moduledoc """
  Input data for calling insert_new_author/1.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @required [:id, :withdrawal]
  @optional []

  @primary_key false
  embedded_schema do
    field :id, :string
    field :withdrawal, :integer
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_number(:withdrawal, greater_than: 0)
  end
end

defmodule BankingApi.Accounts.Inputs.Transfer do
  @moduledoc """
  Input data for calling insert_new_author/1.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @required [:origin, :destiny, :value]

  @primary_key false
  embedded_schema do
    field :origin, Ecto.UUID
    field :destiny, Ecto.UUID
    field :value, :integer
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_number(:value, greater_than: 0)
  end
end

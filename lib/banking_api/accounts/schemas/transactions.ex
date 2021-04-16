defmodule BankingApi.Accounts.Schemas.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankingApi.Accounts.Schemas.Account

  @derive {Jason.Encoder, except: [:__meta__]}

  @fields [:value]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :value, :integer
    field :external, :boolean, default: false
    field :transaction_id, Ecto.UUID
    belongs_to :account, Account

    timestamps(updated_at: false)
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> cast_assoc(:account)
  end
end

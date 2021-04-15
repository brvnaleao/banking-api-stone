defmodule BankingApi.Accounts.Schemas.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankingApi.Users.Schemas.User
  @derive {Jason.Encoder, except: [:__meta__]}

  @fields [:balance]

  # @derive {Jason.Encoder, only: [:user]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :balance, :integer, default: 100_000
    belongs_to :user, User

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end

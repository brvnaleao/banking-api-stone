defmodule BankingApi.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :balance, :integer, default: 100_000
      add :user_id, references(:users, type: :uuid), null: false

      timestamps()
    end

    create constraint(:accounts, "balance_must_be_positive",check: "balance > 0", comment: "Balance must be a positive number")
  end
end

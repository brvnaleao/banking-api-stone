defmodule BankingApi.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :external, :boolean, dafault: false
      add :value, :integer, null: false
      add :account_id, references(:accounts, type: :uuid), null: false

      timestamps()
    end
  end
end

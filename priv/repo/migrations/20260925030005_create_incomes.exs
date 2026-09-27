defmodule App.Repo.Migrations.CreateIncomes do
  use Ecto.Migration

  def change do
    create table(:incomes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, :string
      add :amount, :decimal, default: 0

      add :envelope_id, references(:envelopes, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:incomes, [:account_id])
  end
end

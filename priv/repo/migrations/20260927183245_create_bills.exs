defmodule App.Repo.Migrations.CreateBills do
  use Ecto.Migration

  def change do
    create table(:bills, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, :string
      add :name, :string
      add :amount, :decimal
      add :due_on, :date
      add :paid_at, :date

      timestamps(type: :utc_datetime)
    end

    create index(:bills, [:account_id])
  end
end

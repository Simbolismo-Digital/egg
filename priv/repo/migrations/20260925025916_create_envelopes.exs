defmodule App.Repo.Migrations.CreateEnvelopes do
  use Ecto.Migration

  def change do
    create table(:envelopes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, :string
      add :name, :string
      add :balance, :decimal, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:envelopes, [:account_id])
  end
end

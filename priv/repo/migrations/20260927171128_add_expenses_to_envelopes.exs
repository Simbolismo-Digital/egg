defmodule App.Repo.Migrations.AddExpensesToEnvelopes do
  use Ecto.Migration

  def change do
    alter table(:envelopes) do
      add :expenses, :map, default: fragment("'[]'::jsonb"), null: false
    end
  end
end

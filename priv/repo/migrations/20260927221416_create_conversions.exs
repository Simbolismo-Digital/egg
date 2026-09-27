defmodule App.Repo.Migrations.CreateConversions do
  use Ecto.Migration

  def change do
    create table(:conversions) do
      add :target_currency, :string
      add :amount_in_dollar, :decimal
      add :target_amount, :decimal

      timestamps(type: :utc_datetime)
    end
  end
end

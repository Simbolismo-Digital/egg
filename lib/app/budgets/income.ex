defmodule App.Budgets.Income do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "incomes" do
    field :account_id, :string
    field :amount, :decimal

    field :envelope_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(income, attrs) do
    income
    |> cast(attrs, [:account_id, :amount, :envelope_id])
    |> validate_required([:account_id, :amount])
  end
end

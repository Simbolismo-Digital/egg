defmodule App.Budgets.Bill do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bills" do
    field :account_id, :string
    field :name, :string
    field :amount, :decimal
    field :due_on, :date
    field :paid_at, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bill, attrs) do
    bill
    |> cast(attrs, [:account_id, :name, :amount, :due_on, :paid_at])
    |> validate_required([:account_id, :name, :amount, :due_on])
  end
end

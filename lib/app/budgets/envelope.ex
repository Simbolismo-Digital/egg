defmodule App.Budgets.Envelope do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "envelopes" do
    field :account_id, :string
    field :name, :string
    field :balance, :decimal
    field :expenses, {:array, :map}, default: []

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(envelope, attrs) do
    envelope
    |> cast(attrs, [:account_id, :name, :balance, :expenses])
    |> validate_required([:account_id, :name, :balance])
  end
end

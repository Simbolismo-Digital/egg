defmodule App.Currency.Conversion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversions" do
    field :target_currency, :string
    field :amount_in_dollar, :decimal
    field :target_amount, :decimal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversion, attrs) do
    conversion
    |> cast(attrs, [:target_currency, :amount_in_dollar, :target_amount])
    |> validate_required([:target_currency, :amount_in_dollar])
  end

  def put_target_amount(changeset) do
    require IEx; IEx. pry
  end
end

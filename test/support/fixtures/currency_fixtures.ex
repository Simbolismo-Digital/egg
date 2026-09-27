defmodule App.CurrencyFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Currency` context.
  """

  @doc """
  Generate a conversion.
  """
  def conversion_fixture(attrs \\ %{}) do
    {:ok, conversion} =
      attrs
      |> Enum.into(%{
        amount_in_dollar: "120.5",
        target_amount: "120.5",
        target_currency: "some target_currency"
      })
      |> App.Currency.create_conversion()

    conversion
  end
end

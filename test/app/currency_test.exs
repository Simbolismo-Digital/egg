defmodule App.CurrencyTest do
  use App.DataCase

  alias App.Currency

  describe "source" do
    test "source/0 returns all currency rates" do
      {:ok, rates} = Currency.source()

      assert rates
             |> Map.keys()
             |> length() == 166
    end

    test "source/1 returns a currency rate" do
      {:ok, rate} = Currency.source("BRL")

      assert is_float(rate)
      assert rate > 5
    end
  end
end

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

  describe "conversions" do
    alias App.Currency.Conversion

    import App.CurrencyFixtures

    @invalid_attrs %{target_currency: nil, amount_in_dollar: nil, target_amount: nil}

    test "list_conversions/0 returns all conversions" do
      conversion = conversion_fixture()
      assert Currency.list_conversions() == [conversion]
    end

    test "get_conversion!/1 returns the conversion with given id" do
      conversion = conversion_fixture()
      assert Currency.get_conversion!(conversion.id) == conversion
    end

    test "create_conversion/1 with valid data creates a conversion" do
      valid_attrs = %{target_currency: "some target_currency", amount_in_dollar: "120.5", target_amount: "120.5"}

      assert {:ok, %Conversion{} = conversion} = Currency.create_conversion(valid_attrs)
      assert conversion.target_currency == "some target_currency"
      assert conversion.amount_in_dollar == Decimal.new("120.5")
      assert conversion.target_amount == Decimal.new("120.5")
    end

    test "create_conversion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Currency.create_conversion(@invalid_attrs)
    end

    test "update_conversion/2 with valid data updates the conversion" do
      conversion = conversion_fixture()
      update_attrs = %{target_currency: "some updated target_currency", amount_in_dollar: "456.7", target_amount: "456.7"}

      assert {:ok, %Conversion{} = conversion} = Currency.update_conversion(conversion, update_attrs)
      assert conversion.target_currency == "some updated target_currency"
      assert conversion.amount_in_dollar == Decimal.new("456.7")
      assert conversion.target_amount == Decimal.new("456.7")
    end

    test "update_conversion/2 with invalid data returns error changeset" do
      conversion = conversion_fixture()
      assert {:error, %Ecto.Changeset{}} = Currency.update_conversion(conversion, @invalid_attrs)
      assert conversion == Currency.get_conversion!(conversion.id)
    end

    test "delete_conversion/1 deletes the conversion" do
      conversion = conversion_fixture()
      assert {:ok, %Conversion{}} = Currency.delete_conversion(conversion)
      assert_raise Ecto.NoResultsError, fn -> Currency.get_conversion!(conversion.id) end
    end

    test "change_conversion/1 returns a conversion changeset" do
      conversion = conversion_fixture()
      assert %Ecto.Changeset{} = Currency.change_conversion(conversion)
    end
  end
end

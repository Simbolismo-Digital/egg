defmodule App.BudgetsTest do
  use App.DataCase

  alias App.Budgets

  describe "envelopes" do
    alias App.Budgets.Envelope

    import App.BudgetsFixtures

    @invalid_attrs %{name: nil, balance: nil, account_id: nil}

    test "list_envelopes/0 returns all envelopes" do
      envelope = envelope_fixture()
      assert Budgets.list_envelopes() == [envelope]
    end

    test "get_envelope!/1 returns the envelope with given id" do
      envelope = envelope_fixture()
      assert Budgets.get_envelope!(envelope.id) == envelope
    end

    test "create_envelope/1 with valid data creates a envelope" do
      valid_attrs = %{name: "some name", balance: "120.5", account_id: "some account_id"}

      assert {:ok, %Envelope{} = envelope} = Budgets.create_envelope(valid_attrs)
      assert envelope.name == "some name"
      assert envelope.balance == Decimal.new("120.5")
      assert envelope.account_id == "some account_id"
    end

    test "create_envelope/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Budgets.create_envelope(@invalid_attrs)
    end

    test "update_envelope/2 with valid data updates the envelope" do
      envelope = envelope_fixture()

      update_attrs = %{
        name: "some updated name",
        balance: "456.7",
        account_id: "some updated account_id"
      }

      assert {:ok, %Envelope{} = envelope} = Budgets.update_envelope(envelope, update_attrs)
      assert envelope.name == "some updated name"
      assert envelope.balance == Decimal.new("456.7")
      assert envelope.account_id == "some updated account_id"
    end

    test "update_envelope/2 with invalid data returns error changeset" do
      envelope = envelope_fixture()
      assert {:error, %Ecto.Changeset{}} = Budgets.update_envelope(envelope, @invalid_attrs)
      assert envelope == Budgets.get_envelope!(envelope.id)
    end

    test "delete_envelope/1 deletes the envelope" do
      envelope = envelope_fixture()
      assert {:ok, %Envelope{}} = Budgets.delete_envelope(envelope)
      assert_raise Ecto.NoResultsError, fn -> Budgets.get_envelope!(envelope.id) end
    end

    test "change_envelope/1 returns a envelope changeset" do
      envelope = envelope_fixture()
      assert %Ecto.Changeset{} = Budgets.change_envelope(envelope)
    end
  end

  describe "incomes" do
    alias App.Budgets.Income

    import App.BudgetsFixtures

    @invalid_attrs %{account_id: nil, amount: nil}

    test "list_incomes/0 returns all incomes" do
      income = income_fixture()
      assert Budgets.list_incomes() == [income]
    end

    test "get_income!/1 returns the income with given id" do
      income = income_fixture()
      assert Budgets.get_income!(income.id) == income
    end

    test "create_income/1 with valid data creates a income" do
      valid_attrs = %{account_id: "some account_id", amount: "120.5"}

      assert {:ok, %Income{} = income} = Budgets.create_income(valid_attrs)
      assert income.account_id == "some account_id"
      assert income.amount == Decimal.new("120.5")
    end

    test "create_income/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Budgets.create_income(@invalid_attrs)
    end

    test "update_income/2 with valid data updates the income" do
      income = income_fixture()
      update_attrs = %{account_id: "some updated account_id", amount: "456.7"}

      assert {:ok, %Income{} = income} = Budgets.update_income(income, update_attrs)
      assert income.account_id == "some updated account_id"
      assert income.amount == Decimal.new("456.7")
    end

    test "update_income/2 with invalid data returns error changeset" do
      income = income_fixture()
      assert {:error, %Ecto.Changeset{}} = Budgets.update_income(income, @invalid_attrs)
      assert income == Budgets.get_income!(income.id)
    end

    test "delete_income/1 deletes the income" do
      income = income_fixture()
      assert {:ok, %Income{}} = Budgets.delete_income(income)
      assert_raise Ecto.NoResultsError, fn -> Budgets.get_income!(income.id) end
    end

    test "change_income/1 returns a income changeset" do
      income = income_fixture()
      assert %Ecto.Changeset{} = Budgets.change_income(income)
    end
  end
end

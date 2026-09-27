defmodule App.BudgetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Budgets` context.
  """

  @doc """
  Generate a envelope.
  """
  def envelope_fixture(attrs \\ %{}) do
    {:ok, envelope} =
      attrs
      |> Enum.into(%{
        account_id: "some account_id",
        balance: "120.5",
        name: "some name"
      })
      |> App.Budgets.create_envelope()

    envelope
  end

  @doc """
  Generate a income.
  """
  def income_fixture(attrs \\ %{}) do
    {:ok, income} =
      attrs
      |> Enum.into(%{
        account_id: "some account_id",
        amount: "120.5"
      })
      |> App.Budgets.create_income()

    income
  end

  @doc """
  Generate a bill.
  """
  def bill_fixture(attrs \\ %{}) do
    {:ok, bill} =
      attrs
      |> Enum.into(%{
        account_id: "some account_id",
        amount: "120.5",
        due_on: ~D[2026-09-26],
        name: "some name",
        paid: true
      })
      |> App.Budgets.create_bill()

    bill
  end
end

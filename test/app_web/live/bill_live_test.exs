defmodule AppWeb.BillLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.BudgetsFixtures

  @create_attrs %{name: "some name", amount: "120.5", account_id: "some account_id", due_on: "2026-09-26", paid: true}
  @update_attrs %{name: "some updated name", amount: "456.7", account_id: "some updated account_id", due_on: "2026-09-27", paid: false}
  @invalid_attrs %{name: nil, amount: nil, account_id: nil, due_on: nil, paid: false}
  defp create_bill(_) do
    bill = bill_fixture()

    %{bill: bill}
  end

  describe "Index" do
    setup [:create_bill]

    test "lists all bills", %{conn: conn, bill: bill} do
      {:ok, _index_live, html} = live(conn, ~p"/bills")

      assert html =~ "Listing Bills"
      assert html =~ bill.account_id
    end

    test "saves new bill", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/bills")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Bill")
               |> render_click()
               |> follow_redirect(conn, ~p"/bills/new")

      assert render(form_live) =~ "New Bill"

      assert form_live
             |> form("#bill-form", bill: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#bill-form", bill: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/bills")

      html = render(index_live)
      assert html =~ "Bill created successfully"
      assert html =~ "some account_id"
    end

    test "updates bill in listing", %{conn: conn, bill: bill} do
      {:ok, index_live, _html} = live(conn, ~p"/bills")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#bills-#{bill.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/bills/#{bill}/edit")

      assert render(form_live) =~ "Edit Bill"

      assert form_live
             |> form("#bill-form", bill: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#bill-form", bill: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/bills")

      html = render(index_live)
      assert html =~ "Bill updated successfully"
      assert html =~ "some updated account_id"
    end

    test "deletes bill in listing", %{conn: conn, bill: bill} do
      {:ok, index_live, _html} = live(conn, ~p"/bills")

      assert index_live |> element("#bills-#{bill.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#bills-#{bill.id}")
    end
  end

  describe "Show" do
    setup [:create_bill]

    test "displays bill", %{conn: conn, bill: bill} do
      {:ok, _show_live, html} = live(conn, ~p"/bills/#{bill}")

      assert html =~ "Show Bill"
      assert html =~ bill.account_id
    end

    test "updates bill and returns to show", %{conn: conn, bill: bill} do
      {:ok, show_live, _html} = live(conn, ~p"/bills/#{bill}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/bills/#{bill}/edit?return_to=show")

      assert render(form_live) =~ "Edit Bill"

      assert form_live
             |> form("#bill-form", bill: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#bill-form", bill: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/bills/#{bill}")

      html = render(show_live)
      assert html =~ "Bill updated successfully"
      assert html =~ "some updated account_id"
    end
  end
end

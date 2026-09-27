defmodule AppWeb.EnvelopeLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.BudgetsFixtures

  @create_attrs %{name: "some name", balance: "120.5", account_id: "some account_id"}
  @update_attrs %{
    name: "some updated name",
    balance: "456.7",
    account_id: "some updated account_id"
  }
  @invalid_attrs %{name: nil, balance: nil, account_id: nil}
  defp create_envelope(_) do
    envelope = envelope_fixture()

    %{envelope: envelope}
  end

  describe "Index" do
    setup [:create_envelope]

    test "lists all envelopes", %{conn: conn, envelope: envelope} do
      {:ok, _index_live, html} = live(conn, ~p"/envelopes")

      assert html =~ "Listing Envelopes"
      assert html =~ envelope.account_id
    end

    test "saves new envelope", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/envelopes")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Envelope")
               |> render_click()
               |> follow_redirect(conn, ~p"/envelopes/new")

      assert render(form_live) =~ "New Envelope"

      assert form_live
             |> form("#envelope-form", envelope: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#envelope-form", envelope: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/envelopes")

      html = render(index_live)
      assert html =~ "Envelope created successfully"
      assert html =~ "some account_id"
    end

    test "updates envelope in listing", %{conn: conn, envelope: envelope} do
      {:ok, index_live, _html} = live(conn, ~p"/envelopes")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#envelopes-#{envelope.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/envelopes/#{envelope}/edit")

      assert render(form_live) =~ "Edit Envelope"

      assert form_live
             |> form("#envelope-form", envelope: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#envelope-form", envelope: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/envelopes")

      html = render(index_live)
      assert html =~ "Envelope updated successfully"
      assert html =~ "some updated account_id"
    end

    test "deletes envelope in listing", %{conn: conn, envelope: envelope} do
      {:ok, index_live, _html} = live(conn, ~p"/envelopes")

      assert index_live |> element("#envelopes-#{envelope.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#envelopes-#{envelope.id}")
    end
  end

  describe "Show" do
    setup [:create_envelope]

    test "displays envelope", %{conn: conn, envelope: envelope} do
      {:ok, _show_live, html} = live(conn, ~p"/envelopes/#{envelope}")

      assert html =~ "Show Envelope"
      assert html =~ envelope.account_id
    end

    test "updates envelope and returns to show", %{conn: conn, envelope: envelope} do
      {:ok, show_live, _html} = live(conn, ~p"/envelopes/#{envelope}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/envelopes/#{envelope}/edit?return_to=show")

      assert render(form_live) =~ "Edit Envelope"

      assert form_live
             |> form("#envelope-form", envelope: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#envelope-form", envelope: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/envelopes/#{envelope}")

      html = render(show_live)
      assert html =~ "Envelope updated successfully"
      assert html =~ "some updated account_id"
    end
  end
end

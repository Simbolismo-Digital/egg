defmodule AppWeb.ConversionLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.CurrencyFixtures

  @create_attrs %{target_currency: "some target_currency", amount_in_dollar: "120.5", target_amount: "120.5"}
  @update_attrs %{target_currency: "some updated target_currency", amount_in_dollar: "456.7", target_amount: "456.7"}
  @invalid_attrs %{target_currency: nil, amount_in_dollar: nil, target_amount: nil}
  defp create_conversion(_) do
    conversion = conversion_fixture()

    %{conversion: conversion}
  end

  describe "Index" do
    setup [:create_conversion]

    test "lists all conversions", %{conn: conn, conversion: conversion} do
      {:ok, _index_live, html} = live(conn, ~p"/conversions")

      assert html =~ "Listing Conversions"
      assert html =~ conversion.target_currency
    end

    test "saves new conversion", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/conversions")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Conversion")
               |> render_click()
               |> follow_redirect(conn, ~p"/conversions/new")

      assert render(form_live) =~ "New Conversion"

      assert form_live
             |> form("#conversion-form", conversion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#conversion-form", conversion: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/conversions")

      html = render(index_live)
      assert html =~ "Conversion created successfully"
      assert html =~ "some target_currency"
    end

    test "updates conversion in listing", %{conn: conn, conversion: conversion} do
      {:ok, index_live, _html} = live(conn, ~p"/conversions")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#conversions-#{conversion.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/conversions/#{conversion}/edit")

      assert render(form_live) =~ "Edit Conversion"

      assert form_live
             |> form("#conversion-form", conversion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#conversion-form", conversion: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/conversions")

      html = render(index_live)
      assert html =~ "Conversion updated successfully"
      assert html =~ "some updated target_currency"
    end

    test "deletes conversion in listing", %{conn: conn, conversion: conversion} do
      {:ok, index_live, _html} = live(conn, ~p"/conversions")

      assert index_live |> element("#conversions-#{conversion.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#conversions-#{conversion.id}")
    end
  end

  describe "Show" do
    setup [:create_conversion]

    test "displays conversion", %{conn: conn, conversion: conversion} do
      {:ok, _show_live, html} = live(conn, ~p"/conversions/#{conversion}")

      assert html =~ "Show Conversion"
      assert html =~ conversion.target_currency
    end

    test "updates conversion and returns to show", %{conn: conn, conversion: conversion} do
      {:ok, show_live, _html} = live(conn, ~p"/conversions/#{conversion}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/conversions/#{conversion}/edit?return_to=show")

      assert render(form_live) =~ "Edit Conversion"

      assert form_live
             |> form("#conversion-form", conversion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#conversion-form", conversion: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/conversions/#{conversion}")

      html = render(show_live)
      assert html =~ "Conversion updated successfully"
      assert html =~ "some updated target_currency"
    end
  end
end

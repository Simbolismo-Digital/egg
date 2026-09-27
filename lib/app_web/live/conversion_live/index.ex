defmodule AppWeb.ConversionLive.Index do
  use AppWeb, :live_view

  alias App.Currency

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Conversions
        <:actions>
          <.button variant="primary" navigate={~p"/conversions/new"}>
            <.icon name="hero-plus" /> New Conversion
          </.button>
        </:actions>
      </.header>

      <.table
        id="conversions"
        rows={@streams.conversions}
        row_click={fn {_id, conversion} -> JS.navigate(~p"/conversions/#{conversion}") end}
      >
        <:col :let={{_id, conversion}} label="Target currency">{conversion.target_currency}</:col>
        <:col :let={{_id, conversion}} label="Amount in dollar">{conversion.amount_in_dollar}</:col>
        <:col :let={{_id, conversion}} label="Target amount">{conversion.target_amount}</:col>
        <:action :let={{_id, conversion}}>
          <div class="sr-only">
            <.link navigate={~p"/conversions/#{conversion}"}>Show</.link>
          </div>
          <.link navigate={~p"/conversions/#{conversion}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, conversion}}>
          <.link
            phx-click={JS.push("delete", value: %{id: conversion.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Conversions")
     |> stream(:conversions, list_conversions())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    conversion = Currency.get_conversion!(id)
    {:ok, _} = Currency.delete_conversion(conversion)

    {:noreply, stream_delete(socket, :conversions, conversion)}
  end

  defp list_conversions() do
    Currency.list_conversions()
  end
end

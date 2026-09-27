defmodule AppWeb.ConversionLive.Show do
  use AppWeb, :live_view

  alias App.Currency

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Conversion {@conversion.id}
        <:subtitle>This is a conversion record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/conversions"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/conversions/#{@conversion}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit conversion
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Target currency">{@conversion.target_currency}</:item>
        <:item title="Amount in dollar">{@conversion.amount_in_dollar}</:item>
        <:item title="Target amount">{@conversion.target_amount}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Conversion")
     |> assign(:conversion, Currency.get_conversion!(id))}
  end
end

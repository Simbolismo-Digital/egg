defmodule AppWeb.BillLive.Show do
  use AppWeb, :live_view

  alias App.Budgets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Bill {@bill.id}
        <:subtitle>This is a bill record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/bills"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/bills/#{@bill}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit bill
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Account">{@bill.account_id}</:item>
        <:item title="Name">{@bill.name}</:item>
        <:item title="Amount">{@bill.amount}</:item>
        <:item title="Due on">{@bill.due_on}</:item>
        <:item title="Paid">{@bill.paid}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Bill")
     |> assign(:bill, Budgets.get_bill!(id))}
  end
end

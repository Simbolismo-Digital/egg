defmodule AppWeb.BillLive.Index do
  use AppWeb, :live_view

  alias App.Budgets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Bills
        <:actions>
          <.button variant="primary" navigate={~p"/bills/new"}>
            <.icon name="hero-plus" /> New Bill
          </.button>
        </:actions>
      </.header>

      <.table
        id="bills"
        rows={@streams.bills}
        row_click={fn {_id, bill} -> JS.navigate(~p"/bills/#{bill}") end}
      >
        <:col :let={{_id, bill}} label="Account">{bill.account_id}</:col>
        <:col :let={{_id, bill}} label="Name">{bill.name}</:col>
        <:col :let={{_id, bill}} label="Amount">{bill.amount}</:col>
        <:col :let={{_id, bill}} label="Due on">{bill.due_on}</:col>
        <:col :let={{_id, bill}} label="Paid">{bill.paid}</:col>
        <:action :let={{_id, bill}}>
          <div class="sr-only">
            <.link navigate={~p"/bills/#{bill}"}>Show</.link>
          </div>
          <.link navigate={~p"/bills/#{bill}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, bill}}>
          <.link
            phx-click={JS.push("delete", value: %{id: bill.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Bills")
     |> stream(:bills, list_bills())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bill = Budgets.get_bill!(id)
    {:ok, _} = Budgets.delete_bill(bill)

    {:noreply, stream_delete(socket, :bills, bill)}
  end

  defp list_bills() do
    Budgets.list_bills()
  end
end

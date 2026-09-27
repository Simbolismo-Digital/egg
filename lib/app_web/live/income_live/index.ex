defmodule AppWeb.IncomeLive.Index do
  use AppWeb, :live_view

  alias App.Budgets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Incomes
        <:actions>
          <.button variant="primary" navigate={~p"/incomes/new"}>
            <.icon name="hero-plus" /> New Income
          </.button>
        </:actions>
      </.header>

      <.table
        id="incomes"
        rows={@streams.incomes}
        row_click={fn {_id, income} -> JS.navigate(~p"/incomes/#{income}") end}
      >
        <:col :let={{_id, income}} label="Account">{income.account_id}</:col>
        <:col :let={{_id, income}} label="Amount">{income.amount}</:col>
        <:action :let={{_id, income}}>
          <div class="sr-only">
            <.link navigate={~p"/incomes/#{income}"}>Show</.link>
          </div>
          <.link navigate={~p"/incomes/#{income}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, income}}>
          <.link
            phx-click={JS.push("delete", value: %{id: income.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Incomes")
     |> stream(:incomes, list_incomes())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    income = Budgets.get_income!(id)
    {:ok, _} = Budgets.delete_income(income)

    {:noreply, stream_delete(socket, :incomes, income)}
  end

  defp list_incomes() do
    Budgets.list_incomes()
  end
end

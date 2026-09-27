defmodule AppWeb.EnvelopeLive.Index do
  use AppWeb, :live_view

  alias App.Budgets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Envelopes
        <:actions>
          <.button variant="primary" navigate={~p"/envelopes/new"}>
            <.icon name="hero-plus" /> New Envelope
          </.button>
        </:actions>
      </.header>

      <.table
        id="envelopes"
        rows={@streams.envelopes}
        row_click={fn {_id, envelope} -> JS.navigate(~p"/envelopes/#{envelope}") end}
      >
        <:col :let={{_id, envelope}} label="Account">{envelope.account_id}</:col>
        <:col :let={{_id, envelope}} label="Name">{envelope.name}</:col>
        <:col :let={{_id, envelope}} label="Balance">{envelope.balance}</:col>
        <:action :let={{_id, envelope}}>
          <div class="sr-only">
            <.link navigate={~p"/envelopes/#{envelope}"}>Show</.link>
          </div>
          <.link navigate={~p"/envelopes/#{envelope}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, envelope}}>
          <.link
            phx-click={JS.push("delete", value: %{id: envelope.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Envelopes")
     |> stream(:envelopes, list_envelopes())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    envelope = Budgets.get_envelope!(id)
    {:ok, _} = Budgets.delete_envelope(envelope)

    {:noreply, stream_delete(socket, :envelopes, envelope)}
  end

  defp list_envelopes() do
    Budgets.list_envelopes()
  end
end

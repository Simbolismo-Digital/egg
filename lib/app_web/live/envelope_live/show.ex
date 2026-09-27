defmodule AppWeb.EnvelopeLive.Show do
  use AppWeb, :live_view

  alias App.Budgets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Envelope {@envelope.id}
        <:subtitle>This is a envelope record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/envelopes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/envelopes/#{@envelope}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit envelope
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Account">{@envelope.account_id}</:item>
        <:item title="Name">{@envelope.name}</:item>
        <:item title="Balance">{@envelope.balance}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Envelope")
     |> assign(:envelope, Budgets.get_envelope!(id))}
  end
end

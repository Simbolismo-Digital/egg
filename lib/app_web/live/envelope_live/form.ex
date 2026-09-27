defmodule AppWeb.EnvelopeLive.Form do
  use AppWeb, :live_view

  alias App.Budgets
  alias App.Budgets.Envelope

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage envelope records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="envelope-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:account_id]} type="text" label="Account" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:balance]} type="number" label="Balance" step="any" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Envelope</.button>
          <.button navigate={return_path(@return_to, @envelope)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    envelope = Budgets.get_envelope!(id)

    socket
    |> assign(:page_title, "Edit Envelope")
    |> assign(:envelope, envelope)
    |> assign(:form, to_form(Budgets.change_envelope(envelope)))
  end

  defp apply_action(socket, :new, _params) do
    envelope = %Envelope{}

    socket
    |> assign(:page_title, "New Envelope")
    |> assign(:envelope, envelope)
    |> assign(:form, to_form(Budgets.change_envelope(envelope)))
  end

  @impl true
  def handle_event("validate", %{"envelope" => envelope_params}, socket) do
    changeset = Budgets.change_envelope(socket.assigns.envelope, envelope_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"envelope" => envelope_params}, socket) do
    save_envelope(socket, socket.assigns.live_action, envelope_params)
  end

  defp save_envelope(socket, :edit, envelope_params) do
    case Budgets.update_envelope(socket.assigns.envelope, envelope_params) do
      {:ok, envelope} ->
        {:noreply,
         socket
         |> put_flash(:info, "Envelope updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, envelope))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_envelope(socket, :new, envelope_params) do
    case Budgets.create_envelope(envelope_params) do
      {:ok, envelope} ->
        {:noreply,
         socket
         |> put_flash(:info, "Envelope created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, envelope))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _envelope), do: ~p"/envelopes"
  defp return_path("show", envelope), do: ~p"/envelopes/#{envelope}"
end

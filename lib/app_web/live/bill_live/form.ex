defmodule AppWeb.BillLive.Form do
  use AppWeb, :live_view

  alias App.Budgets
  alias App.Budgets.Bill

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage bill records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="bill-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:account_id]} type="text" label="Account" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:amount]} type="number" label="Amount" step="any" />
        <.input field={@form[:due_on]} type="date" label="Due on" />
        <.input field={@form[:paid]} type="checkbox" label="Paid" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Bill</.button>
          <.button navigate={return_path(@return_to, @bill)}>Cancel</.button>
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
    bill = Budgets.get_bill!(id)

    socket
    |> assign(:page_title, "Edit Bill")
    |> assign(:bill, bill)
    |> assign(:form, to_form(Budgets.change_bill(bill)))
  end

  defp apply_action(socket, :new, _params) do
    bill = %Bill{}

    socket
    |> assign(:page_title, "New Bill")
    |> assign(:bill, bill)
    |> assign(:form, to_form(Budgets.change_bill(bill)))
  end

  @impl true
  def handle_event("validate", %{"bill" => bill_params}, socket) do
    changeset = Budgets.change_bill(socket.assigns.bill, bill_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"bill" => bill_params}, socket) do
    save_bill(socket, socket.assigns.live_action, bill_params)
  end

  defp save_bill(socket, :edit, bill_params) do
    case Budgets.update_bill(socket.assigns.bill, bill_params) do
      {:ok, bill} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bill updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, bill))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_bill(socket, :new, bill_params) do
    case Budgets.create_bill(bill_params) do
      {:ok, bill} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bill created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, bill))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _bill), do: ~p"/bills"
  defp return_path("show", bill), do: ~p"/bills/#{bill}"
end

defmodule AppWeb.IncomeLive.Form do
  use AppWeb, :live_view

  alias App.Budgets
  alias App.Budgets.Income

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage income records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="income-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:account_id]} type="text" label="Account" />
        <.input field={@form[:amount]} type="number" label="Amount" step="any" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Income</.button>
          <.button navigate={return_path(@return_to, @income)}>Cancel</.button>
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
    income = Budgets.get_income!(id)

    socket
    |> assign(:page_title, "Edit Income")
    |> assign(:income, income)
    |> assign(:form, to_form(Budgets.change_income(income)))
  end

  defp apply_action(socket, :new, _params) do
    income = %Income{}

    socket
    |> assign(:page_title, "New Income")
    |> assign(:income, income)
    |> assign(:form, to_form(Budgets.change_income(income)))
  end

  @impl true
  def handle_event("validate", %{"income" => income_params}, socket) do
    changeset = Budgets.change_income(socket.assigns.income, income_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"income" => income_params}, socket) do
    save_income(socket, socket.assigns.live_action, income_params)
  end

  defp save_income(socket, :edit, income_params) do
    case Budgets.update_income(socket.assigns.income, income_params) do
      {:ok, income} ->
        {:noreply,
         socket
         |> put_flash(:info, "Income updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, income))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_income(socket, :new, income_params) do
    case Budgets.create_income(income_params) do
      {:ok, income} ->
        {:noreply,
         socket
         |> put_flash(:info, "Income created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, income))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _income), do: ~p"/incomes"
  defp return_path("show", income), do: ~p"/incomes/#{income}"
end

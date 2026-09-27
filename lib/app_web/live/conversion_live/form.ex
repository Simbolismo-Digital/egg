defmodule AppWeb.ConversionLive.Form do
  use AppWeb, :live_view

  alias App.Currency
  alias App.Currency.Conversion

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage conversion records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="conversion-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:target_currency]} type="text" label="Target currency" />
        <.input field={@form[:amount_in_dollar]} type="number" label="Amount in dollar" step="any" />
        <.input field={@form[:target_amount]} type="number" label="Target amount" step="any" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Conversion</.button>
          <.button navigate={return_path(@return_to, @conversion)}>Cancel</.button>
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
    conversion = Currency.get_conversion!(id)

    socket
    |> assign(:page_title, "Edit Conversion")
    |> assign(:conversion, conversion)
    |> assign(:form, to_form(Currency.change_conversion(conversion)))
  end

  defp apply_action(socket, :new, _params) do
    conversion = %Conversion{}

    socket
    |> assign(:page_title, "New Conversion")
    |> assign(:conversion, conversion)
    |> assign(:form, to_form(Currency.change_conversion(conversion)))
  end

  @impl true
  def handle_event("validate", %{"conversion" => conversion_params}, socket) do
    changeset = Currency.change_conversion(socket.assigns.conversion, conversion_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"conversion" => conversion_params}, socket) do
    save_conversion(socket, socket.assigns.live_action, conversion_params)
  end

  defp save_conversion(socket, :edit, conversion_params) do
    case Currency.update_conversion(socket.assigns.conversion, conversion_params) do
      {:ok, conversion} ->
        {:noreply,
         socket
         |> put_flash(:info, "Conversion updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, conversion))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_conversion(socket, :new, conversion_params) do
    case Currency.create_conversion(conversion_params) do
      {:ok, conversion} ->
        {:noreply,
         socket
         |> put_flash(:info, "Conversion created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, conversion))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _conversion), do: ~p"/conversions"
  defp return_path("show", conversion), do: ~p"/conversions/#{conversion}"
end

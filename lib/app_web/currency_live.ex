defmodule AppWeb.CurrencyLive do
  use AppWeb, :live_view

  alias App.Currency

  def mount(params, _session, socket) do
    account_id = Map.get(params, "account", "demo")

    {:ok, socket |> load()}
  end

  def handle_event("convert", %{"amount" => amount, "target" => currency}, socket) do

    {:noreply, load(socket)}
  end

  defp load(socket) do
    assign(socket, currencies: Currency.last(10))
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl space-y-8 p-6">
      <header>
        <h1 class="text-2xl font-bold">Dollar Currency Converter</h1>
      </header>

      <section class="space-y-2 rounded border p-4">
        <h2 class="font-semibold">Dollar ($) to:</h2>
        <form phx-submit="add_income" class="flex gap-2">
          <input
            type="number"
            step="0.01"
            name="amount"
            placeholder="0.00"
            class="rounded border px-2 py-1"
          />
          <input type="text" name="target" placeholder="BRL" class="rounded border px-2 py-1" />
          <button class="rounded border px-3 py-1">Convert</button>
        </form>
      </section>
    </div>
    """
  end
end

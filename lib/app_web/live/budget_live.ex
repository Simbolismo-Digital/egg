defmodule AppWeb.BudgetLive do
  use AppWeb, :live_view

  alias App.Budgets

  def mount(params, _session, socket) do
    account_id = Map.get(params, "account", "demo")

    {:ok, socket |> assign(account_id: account_id) |> load()}
  end

  def handle_event("add_income", %{"amount" => amount}, socket) do
    Budgets.add_income(socket.assigns.account_id, amount)
    {:noreply, load(socket)}
  end

  def handle_event("new_envelope", %{"name" => name}, socket) do
    Budgets.create_envelope(%{"account_id" => socket.assigns.account_id, "name" => name})
    {:noreply, load(socket)}
  end

  def handle_event("allocate", %{"envelope_id" => id, "amount" => amount}, socket) do
    Budgets.allocate(socket.assigns.account_id, id, amount)
    {:noreply, load(socket)}
  end

  def handle_event("spend", %{"envelope_id" => id, "amount" => amount}, socket) do
    Budgets.spend(id, amount)
    {:noreply, load(socket)}
  end

  defp load(socket) do
    account_id = socket.assigns.account_id

    assign(socket,
      income: Budgets.unallocated_income(account_id),
      entries: Budgets.list_income_entries(account_id),
      envelopes: Budgets.list_envelopes(account_id)
    )
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl space-y-8 p-6">
      <header>
        <h1 class="text-2xl font-bold">Envelope Budget</h1>
        <p class="text-sm opacity-70">account: {@account_id}</p>
      </header>

      <section class="space-y-2 rounded border p-4">
        <h2 class="font-semibold">Unallocated income: {@income}</h2>
        <form phx-submit="add_income" class="flex gap-2">
          <input
            type="number"
            step="0.01"
            name="amount"
            placeholder="0.00"
            class="rounded border px-2 py-1"
          />
          <button class="rounded border px-3 py-1">Add income</button>
        </form>
      </section>

      <section class="space-y-2">
        <h2 class="font-semibold">Envelopes</h2>
        <form phx-submit="new_envelope" class="flex gap-2">
          <input type="text" name="name" placeholder="Groceries" class="rounded border px-2 py-1" />
          <button class="rounded border px-3 py-1">New envelope</button>
        </form>

        <table class="w-full text-left">
          <thead>
            <tr class="border-b">
              <th class="py-2">Name</th>
              <th class="py-2">Balance</th>
              <th class="py-2">Move in</th>
              <th class="py-2">Spend</th>
            </tr>
          </thead>
          <tbody :for={envelope <- @envelopes} class="border-b">
            <tr>
              <td class="py-2">{envelope.name}</td>
              <td class="py-2">{envelope.balance}</td>
              <td class="py-2">
                <form phx-submit="allocate" class="flex gap-1">
                  <input type="hidden" name="envelope_id" value={envelope.id} />
                  <input
                    type="number"
                    step="0.01"
                    name="amount"
                    class="w-24 rounded border px-2 py-1"
                  />
                  <button class="rounded border px-2 py-1">Move</button>
                </form>
              </td>
              <td class="py-2">
                <form phx-submit="spend" class="flex gap-1">
                  <input type="hidden" name="envelope_id" value={envelope.id} />
                  <input
                    type="number"
                    step="0.01"
                    name="amount"
                    class="w-24 rounded border px-2 py-1"
                  />
                  <button class="rounded border px-2 py-1">Spend</button>
                </form>
              </td>
            </tr>
            <tr :if={envelope.expenses != []}>
              <td colspan="4" class="pb-2 pl-4">
                <ul class="text-sm opacity-80">
                  <li
                    :for={expense <- Enum.reverse(envelope.expenses)}
                    class="flex justify-between py-0.5"
                  >
                    <span>{format_time(expense["spent_at"])}</span>
                    <span>-{expense["amount"]}</span>
                  </li>
                </ul>
              </td>
            </tr>
          </tbody>
        </table>
      </section>

      <section class="space-y-2">
        <h2 class="font-semibold">Income ledger</h2>
        <ul class="text-sm">
          <li :for={entry <- @entries} class="border-b py-1">{entry.amount}</li>
        </ul>
      </section>
    </div>
    """
  end

  defp format_time(iso) do
    {:ok, dt, _offset} = DateTime.from_iso8601(iso)
    Calendar.strftime(dt, "%d/%m/%Y %H:%M")
  end
end

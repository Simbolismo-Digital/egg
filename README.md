# App

To start your db `docker compose up db`.

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://phoenix.hexdocs.pm/deployment.html).

# Setup

https://ecto-sql.hexdocs.pm/Ecto.Migration.html
https://ecto.hexdocs.pm/Ecto.Schema.html#module-primitive-types

```sh
mix phx.gen.live Budgets Envelope envelopes account_id:string name:string balance:decimal
mix phx.gen.live Budgets Income incomes account_id:string amount:decimal
```

In **both** migrations, give the decimals a default so arithmetic never hits `nil`:

```elixir
add :balance, :decimal, default: 0
```

```elixir
add :amount, :decimal, default: 0

add :envelope_id, references(:envelopes)
```

Then:

```sh
mix ecto.migrate
```

add to `router.ex`

```ex
live "/envelopes", EnvelopeLive.Index, :index
live "/envelopes/new", EnvelopeLive.Form, :new
live "/envelopes/:id", EnvelopeLive.Show, :show
live "/envelopes/:id/edit", EnvelopeLive.Form, :edit

live "/incomes", IncomeLive.Index, :index
live "/incomes/new", IncomeLive.Form, :new
live "/incomes/:id", IncomeLive.Show, :show
live "/incomes/:id/edit", IncomeLive.Form, :edit
```

# Envelope Budgeting — step by step

Requirements covered:

- view a list of envelopes
- add income
- move income into an envelope (subtracts from income, adds to the envelope)
- spend from an envelope (subtracts from the envelope)

## Modeling

`account_id` is a plain string on **both** tables. It is the scope of everything:
you only see, move and spend money inside one account. No users table, no login —
that comes later, and when it does, `account_id` is the seam it plugs into.

`incomes` is a **ledger**, not a balance. Adding income inserts a positive row;
moving money into an envelope inserts a negative row. Unallocated income is the
sum of the rows for that account. Three things fall out of this:

- no singleton row to get-or-create
- no contended `UPDATE` on income, so no lost-update race
- history for free — you can see every deposit and every allocation

`envelopes.balance` stays a column, because an envelope's balance is a fact you
read constantly and the requirements never ask where it came from.

No constraints, no validation, no tests — as instructed.

---

# Envelope Budgeting - step by step

Requirements covered:

- view a list of envelopes
- add income
- move income into an envelope (subtracts from income, adds to the envelope)
- spend from an envelope (subtracts from the envelope)

## Modeling

`account_id` is a plain string on **both** tables. It is the scope of everything:
you only see, move and spend money inside one account. No users table, no login —
that comes later, and when it does, `account_id` is the seam it plugs into.

`incomes` is a **ledger**, not a balance. Adding income inserts a positive row;
moving money into an envelope inserts a negative row. Unallocated income is the
sum of the rows for that account. Three things fall out of this:

- no singleton row to get-or-create
- no contended `UPDATE` on income, so no lost-update race
- history for free — you can see every deposit and every allocation

`envelopes.balance` stays a column, because an envelope's balance is a fact you
read constantly and the requirements never ask where it came from.

No constraints, no validation, no tests — as instructed.

---

## 3. Relax the generated changesets

`lib/app/budgets/envelope.ex`:

```elixir
def changeset(envelope, attrs) do
  envelope
  |> cast(attrs, [:account_id, :name, :balance])
  |> validate_required([:name])
end
```

`lib/app/budgets/income.ex`:

```elixir
def changeset(income, attrs) do
  income
  |> cast(attrs, [:account_id, :amount, :envelope_id])
  |> validate_required([:account_id, :amount])
end
```

## 4. The context

Create `lib/app/budgets.ex`:

```elixir
defmodule App.Budgets do
  @moduledoc """
  Envelope budgeting, scoped by `account_id`.

  Income is a ledger: positive rows are deposits, negative rows are
  allocations into envelopes. The unallocated balance is their sum.
  """

  import Ecto.Query, warn: false

  alias App.Budgets.Envelope
  alias App.Budgets.Income
  alias App.Repo
  alias Ecto.Multi

  ## Envelopes

  def list_envelopes(account_id) do
    Repo.all(
      from e in Envelope,
        where: e.account_id == ^account_id,
        order_by: e.id
    )
  end

  def get_envelope!(account_id, id) do
    Repo.get_by!(Envelope, id: id, account_id: account_id)
  end

  def create_envelope(account_id, attrs) do
    %Envelope{account_id: account_id, balance: Decimal.new(0)}
    |> Envelope.changeset(attrs)
    |> Repo.insert()
  end

  ## Income

  def unallocated_income(account_id) do
    Repo.one(
      from i in Income,
        where: i.account_id == ^account_id,
        select: coalesce(sum(i.amount), 0)
    )
  end

  def list_income_entries(account_id) do
    Repo.all(
      from i in Income,
        where: i.account_id == ^account_id,
        order_by: [desc: i.id]
    )
  end

  def add_income(account_id, amount) do
    %Income{}
    |> Income.changeset(%{account_id: account_id, amount: to_decimal(amount)})
    |> Repo.insert()
  end

  ## Money movement

  @doc """
  Moves money from unallocated income into one envelope of the same account.

  The negative ledger row and the envelope update go in one transaction —
  this is the only place where money could otherwise evaporate.
  """
  @dialyzer {:no_opaque, allocate: 3}
  def allocate(account_id, envelope_id, amount) do
    amount = to_decimal(amount)
    envelope = get_envelope!(account_id, envelope_id)

    entry =
      Income.changeset(%Income{}, %{
        account_id: account_id,
        amount: Decimal.negate(amount),
        envelope_id: envelope.id
      })

    moved =
      Envelope.changeset(envelope, %{
        balance: Decimal.add(envelope.balance, amount)
      })

    Multi.new()
    |> Multi.insert(:income_entry, entry)
    |> Multi.update(:envelope, moved)
    |> Repo.transaction()
  end

  def spend(account_id, envelope_id, amount) do
    envelope = get_envelope!(account_id, envelope_id)

    envelope
    |> Envelope.changeset(%{balance: Decimal.sub(envelope.balance, to_decimal(amount))})
    |> Repo.update()
  end

  ## Helpers

  defp to_decimal(%Decimal{} = value), do: value
  defp to_decimal(value) when is_integer(value), do: Decimal.new(value)
  defp to_decimal(value) when is_float(value), do: Decimal.from_float(value)

  defp to_decimal(value) when is_binary(value) do
    case Decimal.parse(value) do
      {decimal, _rest} -> decimal
      :error -> Decimal.new(0)
    end
  end
end
```

`get_envelope!/2` taking the account is what enforces the scope: an envelope id
from another account simply does not resolve, so a transfer can never cross
accounts.

## 5. One LiveView for everything

Create `lib/app_web/live/budget_live.ex`:

```elixir
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
    Budgets.create_envelope(socket.assigns.account_id, %{"name" => name})
    {:noreply, load(socket)}
  end

  def handle_event("allocate", %{"id" => id, "amount" => amount}, socket) do
    Budgets.allocate(socket.assigns.account_id, id, amount)
    {:noreply, load(socket)}
  end

  def handle_event("spend", %{"id" => id, "amount" => amount}, socket) do
    Budgets.spend(socket.assigns.account_id, id, amount)
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
          <tbody>
            <tr :for={envelope <- @envelopes} class="border-b">
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
end
```

Plain HTML inputs on purpose — no dependency on whatever the core components
look like in this Phoenix version.

## 6. Routes

In `lib/app_web/router.ex`, inside the browser scope, replace the home route:

```elixir
live "/", BudgetLive
live "/:account", BudgetLive
```

Two lines, and accounts are visible: `/` is the `demo` account, `/rei` is another
one, with its own income and its own envelopes.

## 7. Run

```sh
mix phx.server
```

## 8. Last notes

```sh
mix ecto.gen.migration add_expenses_to_envelopes
```

```elixir
def change do
  alter table(:envelopes) do
    add :expenses, :map, default: fragment("'[]'::jsonb"), null: false
  end
end
```

```sh
git rm test/app_web/controllers/page_controller_test.exs \
       lib/app_web/controllers/page_controller.ex \
       lib/app_web/controllers/page_html.ex \
       lib/app_web/controllers/page_html/home.html.heex
```

---

## Demo order for a screencast

1. add income → unallocated goes up, a positive row appears in the ledger
2. create two envelopes → list shows them at 0
3. move into one → income down, envelope up, negative row in the ledger (the interesting one)
4. spend from it → envelope down, ledger untouched
5. change the URL to another account → separate money, same app
6. reload → numbers survive

# Use Case 2

2. Bills to pay (:date, :boolean)
A bills table with name, amount, due_on :date, paid :boolean, and the envelope the money comes from. Use cases: list the bills due in the next 7 days, and "pay" a bill, which sets paid: true and debits the envelope in the same transaction, reusing the balance rule from spend.


```sh
mix phx.gen.live Budgets Bill bills account_id:string name:string amount:decimal due_on:date paid:boolean
```

router.ex
```elixir
    live "/bills", BillLive.Index, :index
    live "/bills/new", BillLive.Form, :new
    live "/bills/:id", BillLive.Show, :show
    live "/bills/:id/edit", BillLive.Form, :edit
```

migration/create_bills
```elixir
create table(:bills, primary_key: false) do
      add :id, :binary_id, primary_key: true
...
  create index(:bills, [:account_id])
```

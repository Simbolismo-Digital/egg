defmodule App.Budgets do
  @moduledoc """
  The Budgets context.
  """

  import Ecto.Query, warn: false

  alias App.Budgets.Envelope
  alias App.Budgets.Income
  alias App.Repo
  alias Ecto.Multi

  @doc """
  Returns the list of envelopes.

  ## Examples

      iex> list_envelopes()
      [%Envelope{}, ...]

  """
  def list_envelopes do
    Repo.all(Envelope)
  end

  def list_envelopes(account_id) do
    Repo.all(
      from e in Envelope,
        where: e.account_id == ^account_id,
        order_by: e.id
    )
  end

  @doc """
  Gets a single envelope.

  Raises `Ecto.NoResultsError` if the Envelope does not exist.

  ## Examples

      iex> get_envelope!(123)
      %Envelope{}

      iex> get_envelope!(456)
      ** (Ecto.NoResultsError)

  """
  def get_envelope!(id), do: Repo.get!(Envelope, id)

  @doc """
  Creates a envelope.

  ## Examples

      iex> create_envelope(%{field: value})
      {:ok, %Envelope{}}

      iex> create_envelope(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_envelope(attrs) do
    %Envelope{balance: Decimal.new(0)}
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
    envelope = get_envelope!(envelope_id)

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

  def spend(envelope_id, amount) do
    amount = to_decimal(amount)

    if Decimal.gt?(amount, 0) do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      expense = %{
        "amount" => Decimal.to_string(amount),
        "spent_at" => DateTime.to_iso8601(now)
      }

      query =
        from e in Envelope,
          where: e.id == ^envelope_id and e.balance >= ^amount,
          select: e,
          update: [
            inc: [balance: ^Decimal.negate(amount)],
            set: [
              expenses: fragment("? || ?::jsonb", e.expenses, ^[expense]),
              updated_at: ^now
            ]
          ]

      case Repo.update_all(query, []) do
        {1, [envelope]} ->
          {:ok, envelope}

        {0, []} ->
          if Repo.exists?(from e in Envelope, where: e.id == ^envelope_id),
            do: {:error, :insufficient_balance},
            else: {:error, :not_found}
      end
    else
      {:error, :invalid_amount}
    end
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

  @doc """
  Updates a envelope.

  ## Examples

      iex> update_envelope(envelope, %{field: new_value})
      {:ok, %Envelope{}}

      iex> update_envelope(envelope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_envelope(%Envelope{} = envelope, attrs) do
    envelope
    |> Envelope.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a envelope.

  ## Examples

      iex> delete_envelope(envelope)
      {:ok, %Envelope{}}

      iex> delete_envelope(envelope)
      {:error, %Ecto.Changeset{}}

  """
  def delete_envelope(%Envelope{} = envelope) do
    Repo.delete(envelope)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking envelope changes.

  ## Examples

      iex> change_envelope(envelope)
      %Ecto.Changeset{data: %Envelope{}}

  """
  def change_envelope(%Envelope{} = envelope, attrs \\ %{}) do
    Envelope.changeset(envelope, attrs)
  end

  alias App.Budgets.Income

  @doc """
  Returns the list of incomes.

  ## Examples

      iex> list_incomes()
      [%Income{}, ...]

  """
  def list_incomes do
    Repo.all(Income)
  end

  @doc """
  Gets a single income.

  Raises `Ecto.NoResultsError` if the Income does not exist.

  ## Examples

      iex> get_income!(123)
      %Income{}

      iex> get_income!(456)
      ** (Ecto.NoResultsError)

  """
  def get_income!(id), do: Repo.get!(Income, id)

  @doc """
  Creates a income.

  ## Examples

      iex> create_income(%{field: value})
      {:ok, %Income{}}

      iex> create_income(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_income(attrs) do
    %Income{}
    |> Income.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a income.

  ## Examples

      iex> update_income(income, %{field: new_value})
      {:ok, %Income{}}

      iex> update_income(income, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_income(%Income{} = income, attrs) do
    income
    |> Income.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a income.

  ## Examples

      iex> delete_income(income)
      {:ok, %Income{}}

      iex> delete_income(income)
      {:error, %Ecto.Changeset{}}

  """
  def delete_income(%Income{} = income) do
    Repo.delete(income)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking income changes.

  ## Examples

      iex> change_income(income)
      %Ecto.Changeset{data: %Income{}}

  """
  def change_income(%Income{} = income, attrs \\ %{}) do
    Income.changeset(income, attrs)
  end
end

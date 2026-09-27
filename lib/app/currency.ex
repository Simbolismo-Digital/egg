defmodule App.Currency do
  @source_url "https://open.er-api.com/v6/latest/USD"

  def source(currency) do
    case source() do
      {:ok, rates} ->
        case rates[currency] do
          nil -> {:error, :not_found}
          rate -> {:ok, rate}
        end
      {:error, error} -> {:error, error}
    end
  end

  def source do
    case Req.get!(@source_url) do
      %{status: 200, body: body} ->
        parsed(body)
      _ ->
        {:error, :api_error}
    end
  end

  def parsed(%{"rates" => rates}) do
    {:ok, rates}
  end

  def parsed(_) do
    {:error, :api_invalid_format}
  end
end

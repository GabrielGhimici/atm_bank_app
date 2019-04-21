defmodule Bank.Conversion do
  @moduledoc false
  use Agent

  @doc """
  Starts a new agent that provides conversion functionality.
  """
  def start_link(_opts) do
    map =
      case Bank.Database.get_conversion_rate() do
        {:ok, raw_data} ->
          List.foldl(raw_data, %{}, fn x, acc ->
            Map.put(acc, List.first(x), List.last(x))
          end)
        {:error, _msg} -> %{}
      end
    Agent.start_link(fn -> map end, name: __MODULE__)
  end

  def convert(sum, currency) do
    state = get_state()
    optimized_currency = String.downcase(currency)
    if Map.has_key?(state, optimized_currency) do
      {rate, _rate_rest} = Float.parse(Map.get(state, optimized_currency))
      {parsed_sum, _rest} = Float.parse(sum)
      new_sum = parsed_sum * rate
      {:ok, "#{new_sum}"}
    else
      Agent.stop(__MODULE__)
      {:fail, sum}
    end
  end

  defp get_state() do
    Agent.get(__MODULE__,& &1)
  end
end

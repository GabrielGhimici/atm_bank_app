defmodule Bank.Database do
  @moduledoc false
  use Agent

  @doc """
  Starts a new agent that makes accounts persistent.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Get balance for account.
  """
  def get_amount(account_id) do
    case File.read("database/accounts/#{account_id}.txt") do
      {:ok, amount} ->
        {value, rest} = Float.parse(amount)
        value
      {:error, :enoent} -> {:error, "NO DATA FOUND FOR THIS USER\r\n"}
    end
  end

  @doc """
  Makes account state persistent.
  """
  def make_account_persistent(account_id, ammount) do
    case File.write("database/accounts/#{account_id}.txt", Float.to_string(ammount), []) do
      :ok -> {:ok, "ACCOUNT UPDATED\r\n"}
      {:error, :enoent} -> {:error, "NO DATA FOUND FOR THIS USER\r\n"}
    end
  end

  @doc """
  Get exchange rates.
  """
  def get_conversion_rate() do
    case File.read("database/conversion_rate.txt") do
      {:ok, rates} ->
        conversion_raw = for rate <- String.split(rates, "/"), do: String.split(rate, "=")
        {:ok, conversion_raw}
      {:error, :enoent} -> {:error, "NO DATA FOUND FOR THIS USER\r\n"}
    end
  end
end

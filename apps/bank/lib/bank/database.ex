defmodule Bank.Database do
  @moduledoc false
  use Agent, restart: :temporary

  @doc """
  Starts a new agent that makes accounts persistent.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  def get_ammount(account_id) do
    case File.read("accounts/#{account_id}.txt") do
      {:ok, ammount} -> String.to_integer(ammount)
      {:error, :enoent} -> {:error, "NO DATA FOUND FOR THIS USER\r\n"}
    end
  end

  @doc """
  Makes account state persistent.
  """
  def make_account_persistent(account_id, ammount) do
    case File.write("accounts/#{account_id}.txt", Integer.to_string(ammount), []) do
      :ok -> {:ok, "ACCOUNT UPDATED\r\n"}
      {:error, :enoent} -> {:error, "NO DATA FOUND FOR THIS USER\r\n"}
    end
  end

end

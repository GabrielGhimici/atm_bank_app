defmodule Atm.Action do
  @moduledoc false
  require GenServer

  def deserialize(line) do
    case String.split(line) do
      ["CONNECT", account_id] -> {:ok, {:connect, account_id}}
      ["GET_BALANCE", account_id] -> {:ok, {:balance, account_id}}
      ["WITHDRAW", account_id, amount, currency] -> {:ok, {:withdraw,  account_id, amount, currency}}
      ["WITHDRAW", account_id, amount] -> {:ok, {:withdraw,  account_id, amount}}
      ["DEPOSIT", account_id, amount, currency] -> {:ok, {:deposit,  account_id, amount, currency}}
      ["DEPOSIT", account_id, amount] -> {:ok, {:deposit,  account_id, amount}}
      _ -> {:error, :unknown_command}
    end
  end

  def run(action)

  def run({:connect, account_id}) do
    case lookup(account_id) do
      {:ok, _pid} -> {:ok, "CONNECTED SUCCESSFUL\r\n"}
      {:error, :not_found} ->
        GenServer.cast(Bank.Central, {:create, account_id})
        {:ok, "CONNECTION CREATED\r\n"}
    end
  end

  def run({:balance, account_id}) do
    case lookup(account_id) do
      {:ok, pid} ->
        {:ok, amount} = GenServer.call(Bank.Central, {:balance, pid})
        {:ok, "AVAILABLE SUM: #{amount}\r\n"}
      {:error, :not_found} -> {:error, "OPERATION FAILED! THERE IS AN ISSUE WITH YOUR ID.\r\n"}
    end
  end

  def run({:withdraw,  account_id, amount, currency}) do
    case lookup(account_id) do
      {:ok, pid} ->
        case Bank.Conversion.convert(amount, currency) do
          {:ok, sum} ->
            case GenServer.call(Bank.Central, {:withdraw, pid, sum}) do
              {:ok, amount} -> {:ok, "NEW BALANCE IS: #{amount}\r\n"}
              {:error, message} -> {:ok, message}
            end
          {:fail, _sum} -> {:ok, "UNSUPPORTED CURRENCY\r\n"}
        end
      {:error, :not_found} -> {:error, "OPERATION FAILED! THERE IS AN ISSUE WITH YOUR ID.\r\n"}
    end
  end

  def run({:deposit,  account_id, amount, currency}) do
    case lookup(account_id) do
      {:ok, pid} ->
        case Bank.Conversion.convert(amount, currency) do
          {:ok, sum} ->
            {:ok, amount} = GenServer.call(Bank.Central, {:deposit, pid, sum})
            {:ok, "NEW BALANCE IS: #{amount}\r\n"}
          {:fail, _sum} -> {:ok, "UNSUPPORTED CURRENCY\r\n"}
        end
      {:error, :not_found} -> {:error, "OPERATION FAILED! THERE IS AN ISSUE WITH YOUR ID.\r\n"}
    end
  end

  def run({:withdraw,  account_id, amount}) do
    case lookup(account_id) do
      {:ok, pid} ->
        case GenServer.call(Bank.Central, {:withdraw, pid, amount}) do
          {:ok, amount} -> {:ok, "NEW BALANCE IS: #{amount}\r\n"}
          {:error, message} -> {:ok, message}
        end
      {:error, :not_found} -> {:error, "OPERATION FAILED! THERE IS AN ISSUE WITH YOUR ID.\r\n"}
    end
  end

  def run({:deposit,  account_id, amount}) do
    case lookup(account_id) do
      {:ok, pid} ->
        {:ok, amount} = GenServer.call(Bank.Central, {:deposit, pid, amount})
        {:ok, "NEW BALANCE IS: #{amount}\r\n"}
      {:error, :not_found} -> {:error, "OPERATION FAILED! THERE IS AN ISSUE WITH YOUR ID.\r\n"}
    end
  end

  defp lookup(account_id) do
    case GenServer.call(Bank.Central, {:lookup, account_id}) do
      {:ok, pid} -> {:ok, pid}
      :error -> {:error, :not_found}
    end
  end
end

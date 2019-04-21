defmodule Bank.Central do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(_opts) do
    names = %{}
    DynamicSupervisor.start_child(Bank.DatabaseSupervisor, Bank.Database)
    DynamicSupervisor.start_child(Bank.ConversionSupervisor, Bank.Conversion)
    {:ok, names}
  end

  def handle_call(msg, _from, state) do
    case msg do
      {:lookup, account_id}        -> {:reply, Map.fetch(state, account_id), state}
      {:balance, account}          -> {:reply, Bank.Account.get_balance(account), state}
      {:withdraw, account, amount} -> {:reply, Bank.Account.withdraw(account, amount), state}
      {:deposit, account, amount}  -> {:reply, Bank.Account.deposit(account, amount), state}
      _                            -> {:reply, {:error, :unknown_error}, state}
    end
  end

  def handle_cast({:create, name}, state) do
    if Map.has_key?(state, name) do
      {:noreply, state}
    else
      spec = {Bank.Account, {:client, name}}
      {:ok, account} = DynamicSupervisor.start_child(Bank.AccountSupervisor,spec)
      {:noreply, Map.put(state, name, account)}
    end
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
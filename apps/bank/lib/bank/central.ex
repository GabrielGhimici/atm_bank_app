defmodule Bank.Central do
  @moduledoc false

  use GenServer

  def init(_opts) do
    names = %{}
    {:ok, names}
  end

  def handle_call(msg, _from, state) do
    case msg do
      {:lookup, account_id}          -> {:reply, Map.fetch(state, account_id), state}
      {:balance, account}            -> Bank.Account.get_balance(account)
      {:withdraw, account, amount}   -> Bank.Account.withdraw(account, amount)
      {:deposit, account, amount}    -> Bank.Account.deposit(account, amount)
    end
  end

  def handle_cast({:create, name}, state) do
    if Map.has_key?(state, name) do
      {:noreply, state}
    else
      {:ok, account} = Bank.Account.start_link([])
      {:noreply, Map.put(state, name, account)}
    end
  end
end
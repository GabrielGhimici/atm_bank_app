defmodule Bank.Account do
  @moduledoc false
  use Agent

  @doc """
  Starts a new agent that handles an account.
  """
  def start_link(opt) do
    {:client, name} = opt
    amount = Bank.Database.get_amount(name)
    Agent.start_link(fn -> %{balance: amount, user: name} end)
  end

  @doc """
  Provide balance value for a given account.
  """
  def get_balance(account) do
    {:ok, Agent.get(account, &Map.get(&1, :balance))}
  end

  @doc """
  Withdraw `amount` money from `account` if possible, else return an error.
  """
  def withdraw(account, amount) do
    {:ok, current_balance} = get_balance(account)
    {parsed_amount, _amount_rest} = Float.parse(amount)
    new_balance = current_balance - parsed_amount
    if new_balance >= 0 do
      Agent.update(account, &Map.put(&1, :balance, new_balance))
      name=Agent.get(account, &Map.get(&1, :user))
      Bank.Database.make_account_persistent(name, new_balance)
      {:ok, new_balance}
    else
      {:error, "Not enough money to withdraw"}
    end
  end

  @doc """
  """
  def deposit(account, amount) do
    {:ok, current_balance} = get_balance(account)
    {parsed_amount, _amount_rest} = Float.parse(amount)
    new_balance = current_balance + parsed_amount
    Agent.update(account, &Map.put(&1, :balance, new_balance))
    name=Agent.get(account, &Map.get(&1, :user))
    Bank.Database.make_account_persistent(name, new_balance)
    {:ok, new_balance}
  end

end

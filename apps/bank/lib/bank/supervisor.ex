defmodule Bank.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(_arg) do
    children = [
      {DynamicSupervisor, name: Bank.DatabaseSupervisor, strategy: :one_for_one},
      {DynamicSupervisor, name: Bank.ConversionSupervisor, strategy: :one_for_one},
      {DynamicSupervisor, name: Bank.AccountSupervisor, strategy: :one_for_one},
      {Bank.Central, name: Bank.Central}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
defmodule Atm.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(_arg) do
    port = String.to_integer(System.get_env("ATM_PORT") || "3000")
    children = [
      {Task.Supervisor, name: Atm.TaskSupervisor},
      {Task, fn -> Atm.accept(port) end}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
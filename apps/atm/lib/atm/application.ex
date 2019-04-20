defmodule Atm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Atm.Supervisor.start_link(name: Atm.Supervisor)
  end
end

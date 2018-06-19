defmodule Clex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    
    # List all child processes to be supervised
    children = [
      worker(Redix, [[], [name: :redix]]),
      worker(Clex.Periodically, []),
      # Starts a worker by calling: Clex.Worker.start_link(arg)
      # {Clex.Worker, arg},
    ]

#    {:ok, _} = Application.ensure_all_started(:hound)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Clex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

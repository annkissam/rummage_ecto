defmodule RummageTester.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    children = [
      supervisor(RummageTester.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: RummageTester.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

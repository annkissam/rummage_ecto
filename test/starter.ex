defmodule Rumamge.Ecto.Test.Starter do
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Rummage.Ecto.Test.Repo, []),
    ]

    opts = [strategy: :one_for_one, name: Test.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

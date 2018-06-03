defmodule RummageTester.Case do
  @moduledoc false

  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RunnageTester.Repo)
  end
end

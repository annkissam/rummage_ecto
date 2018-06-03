defmodule RummageTester.Employee do
  @moduledoc """
  This is an example usage of `Rummage.Ecto.Schema`. This module has no
  `primary_key` and three fields.

  This also has examples of using fragments to define a custom `rummage_field`.
  """

  use Rummage.Ecto.Schema

  @primary_key false

  schema "employees" do
    field :first_name, :string
    field :last_name, :string
    field :date_of_birth, :date

    timestamps()
  end
end

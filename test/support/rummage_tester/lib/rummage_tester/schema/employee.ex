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

  rummage_field :year_of_birth do
    {:fragment, "date_part('year', ?)", :date_of_birth}
  end

  rummage_field :name do
    {:fragment, "concat(?, ?)", :first_name, :last_name}
  end
end

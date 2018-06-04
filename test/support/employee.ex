defmodule Rummage.Ecto.Employee do
  @moduledoc """
  This is Product Ecto.Schema for testing Rummage.Ecto with float values
  and boolean values
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

  rummage_field :month_of_birth do
    {:fragment, "date_part('month', ?)", :date_of_birth}
  end

  rummage_field :first_name_or_last_name do
    {:fragment, "coalesce(?, ?)", :first_name, :last_name}
  end

  rummage_field :name do
    {:fragment, "concat(?, ?)", :first_name, :last_name}
  end
end

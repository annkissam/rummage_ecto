defmodule Rummage.Ecto.Employee do
  @moduledoc """
  This is Product Ecto.Schema for testing Rummage.Ecto with float values
  and boolean values
  """

  use Rummage.Ecto.Schema

  schema "employees" do
    field :first_name, :string
    field :last_name, :string
    field :price, :float
    field :available, :boolean
    belongs_to :category, Rummage.Ecto.Category

    timestamps()
  end

  rummage_field :month do
    quote(do: fragment("date_part('month', ?)", q.inserted_at))
  end

  rummage_field :name do
    quote(do: fragment("concat(?, ?)", q.first_name, q.last_name))
  end

  def get_month(queryable) do
    queryable |> select([q], month())
  end

  def get_name(queryable) do
    queryable |> select([q], name())
  end
end

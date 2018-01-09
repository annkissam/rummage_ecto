defmodule Rummage.Ecto.Product do
  @moduledoc """
  This is Product Ecto.Schema for testing Rummage.Ecto with float values
  and boolean values
  """
  use Ecto.Schema
  use Rummage.Ecto, per_page: 1

  schema "products" do
    field :name, :string
    field :price, :float
    field :available, :boolean
    belongs_to :category, Rummage.Ecto.Category

    timestamps()
  end
end

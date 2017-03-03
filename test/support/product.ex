defmodule Rummage.Ecto.Product do
  use Ecto.Schema
  use Rummage.Ecto, repo: Rummage.Ecto.Repo

  schema "products" do
    field :name, :string
    field :price, :float
    belongs_to :category, Rummage.Ecto.Category

    timestamps
  end
end

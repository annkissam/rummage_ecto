defmodule Rummage.Ecto.Category do
  use Ecto.Schema
  use Rummage.Ecto

  schema "categories" do
    field :category_name, :string
    belongs_to :category, Rummage.Ecto.Category

    timestamps()
  end
end

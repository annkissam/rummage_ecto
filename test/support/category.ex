defmodule Rummage.Ecto.Category do
  use Ecto.Schema

  schema "categories" do
    field :category_name, :string
    belongs_to :category, Rummage.Ecto.Category

    timestamps
  end
end

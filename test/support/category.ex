defmodule Rummage.Ecto.Category do
  @moduledoc """
  This is a Category Ecto.Schema for testing Rummage.Ecto with a nested
  associations
  """
  use Ecto.Schema
  use Rummage.Ecto

  schema "categories" do
    field :category_name, :string
    belongs_to :category, Rummage.Ecto.Category

    timestamps()
  end
end

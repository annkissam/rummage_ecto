defmodule Rummage.Ecto.Category do
  @moduledoc """
  This is a Category Ecto.Schema for testing Rummage.Ecto with a nested
  associations
  """

  use Rummage.Ecto.Schema

  schema "categories" do
    field :name, :string
    field :description, :string

    belongs_to :parent_category, __MODULE__

    timestamps()
  end
end

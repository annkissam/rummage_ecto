defmodule RummageTester.Category do
  @moduledoc """
  This is an example usage of `Rummage.Ecto.Schema`. This module has `id` as
  `primary_key` and has two fields and a `belongs_to` association.
  """

  use Rummage.Ecto.Schema

  schema "categories" do
    field :name, :string
    field :description, :string

    belongs_to :parent_category, __MODULE__

    timestamps()
  end
end

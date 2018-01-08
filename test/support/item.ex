defmodule Rummage.Ecto.Item do
  @moduledoc """
  This module was created to test Rummage.Ecto with a Schema that doesn't
  have a primary_key of :id.
  """

  use Ecto.Schema

  @primary_key {:item_id, :id, autogenerate: false}

  schema "items" do
    field :item_price, :float
    belongs_to :category, Rummage.Ecto.Category

    timestamps()
  end
end

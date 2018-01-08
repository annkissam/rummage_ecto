defmodule Rummage.Ecto.Nopk do
  @moduledoc """
  This module was created to test Rummage.Ecto with a Schema that doesn't
  have any primary_key.
  """

  use Ecto.Schema

  @primary_key false

  schema "nopks" do
    field :field, :float

    timestamps()
  end
end

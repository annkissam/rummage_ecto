defmodule Rummage.Ecto.Test.Parent do
  use Ecto.Schema

  embedded_schema do
    field :field_1, :string
    field :field_2, :integer
  end
end

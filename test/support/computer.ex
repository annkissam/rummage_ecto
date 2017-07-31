defmodule Rummage.Ecto.Computer do
  use Ecto.Schema

  @primary_key false

  schema "computers" do
    field :name, :string
    field :price, :float

    timestamps()
  end
end

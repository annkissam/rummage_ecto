defmodule RummageTester.Product do
  @moduledoc false

  use Rummage.Ecto.Schema

  @primary_key {:internal_code, :string, autogenerate: false}

  schema "products" do
    field :name, :string
    field :price, :float
    field :availability, :boolean
    field :description, :string

    belongs_to :category, RummageTester.Category

    timestamps()
  end

  rummage_field :created_at_month do
    {:fragment, "date_part('month', ?)", :inserted_at}
  end

  search_scope :category_name do
    fn (term) ->
      %{name: %{assoc: [:category], search_term: term, search_type: :ilike}}
    end
  end
end

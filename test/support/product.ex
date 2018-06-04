defmodule Rummage.Ecto.Product do
  @moduledoc """
  This is Product Ecto.Schema for testing Rummage.Ecto with float values
  and boolean values
  """
  use Rummage.Ecto.Schema, per_page: 1

  @primary_key {:internal_code, :string, autogenerate: false}

  schema "products" do
    field :name, :string
    field :price, :float
    field :availability, :boolean
    field :description, :string

    belongs_to :category, Rummage.Ecto.Category

    timestamps()
  end

  rummage_field :created_at_year do
    {:fragment, "date_part('year', ?)", :inserted_at}
  end

  rummage_field :created_at_month do
    {:fragment, "date_part('month', ?)", :inserted_at}
  end

  rummage_field :created_at_day do
    {:fragment, "date_part('day', ?)", :inserted_at}
  end

  rummage_field :created_at_hour do
    {:fragment, "date_part('hour', ?)", :inserted_at}
  end

  rummage_field :upper_case_name do
    {:fragment, "upper(?)", :name}
  end

  rummage_field :name_or_description do
    {:fragment, "coalesce(?, ?)", :name, :description}
  end

  rummage_scope :category_name, [type: :search], fn(term) ->
    {:name, %{assoc: [inner: :category], search_term: term, search_type: :ilike}}
  end

  rummage_scope :category_name, [type: :sort], fn ->
    %{field: :name, assoc: [inner: :category], order: :asc, ci: :true}
  end

  rummage_scope :product_index, [type: :paginate], fn ->
    %{per_page: 10, page: 1}
  end

  rummage_scope :category_show, [type: :paginate], fn ->
    %{per_page: 5, page: 1}
  end
end

defmodule Rummage.Ecto.Product do
  @moduledoc """
  This is Product Ecto.Schema for testing Rummage.Ecto with float values
  and boolean values
  """
  use Rummage.Ecto.Schema, per_page: 1,
    search: Rummage.Ecto.Hook.CustomSearch,
    sort: Rummage.Ecto.Hook.CustomSort,
    paginate: Rummage.Ecto.Hook.CustomPaginate

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

  rummage_scope :category_name, [type: :sort], fn(order) ->
    %{field: :name, assoc: [inner: :category], order: order, ci: :true}
  end

  rummage_scope :product_index, [type: :paginate], fn(page) ->
    %{per_page: 10, page: page}
  end

  rummage_scope :category_show, [type: :paginate], fn(page) ->
    %{per_page: 5, page: page}
  end

  rummage_scope :category_quarter, [type: :custom_search], fn({query, term}) ->
    query
    |> join(:inner, [q], c in Rummage.Ecto.Category, q.category_id == c.id)
    |> where([..., c], fragment("date_part('quarter', ?)", c.inserted_at) == ^term)
  end

  rummage_scope :category_microseconds, [type: :custom_sort], fn({query, order}) ->
    query
    |> join(:inner, [q], c in Rummage.Ecto.Category, q.category_id == c.id)
    |> order_by([..., c], [{^order, fragment("date_part('microseconds', ?)", c.inserted_at)}])
  end

  rummage_scope :small_page, [type: :custom_paginate], fn({query, page}) ->
    offset = 5 * (page - 1)

    query
    |> limit(5)
    |> offset(^offset)
  end
end

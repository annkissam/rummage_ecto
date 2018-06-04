defmodule RummageTester do
  @moduledoc false

  alias __MODULE__.{Category, Employee, Product}

  @paginate %{per_page: 5, page: 1}

  def list_products(opts) do
    opts
    |> list_products_query()
    |> (fn {q, _} -> q end).()
    |> RummageTester.Repo.all()
  end

  def list_employees(opts) do
    opts
    |> list_employees_query()
    |> (fn {q, _} -> q end).()
    |> RummageTester.Repo.all()
  end

  def list_employees_query(name: name) do
    Employee.rummage(%{
      search: %{name: %{assoc: [], search_term: name, search_type: :ilike}},
      sort: %{assoc: [], field: :last_name, order: :asc},
      paginate: @paginate})
  end

  def list_employees_query(year_of_birth: year_of_birth) do
    Employee.rummage(%{
      search: %{year_of_birth: %{assoc: [], search_term: year_of_birth, search_type: :eq}},
      sort: %{assoc: [], field: :last_name, order: :asc},
      paginate: @paginate})
  end

  def list_products_query(name: name) do
    Product.rummage(%{
      search: %{name: %{assoc: [], search_term: name, search_type: :ilike}},
      sort: %{assoc: [], field: :price, order: :asc},
      paginate: @paginate})
  end

  def list_products_query(created_at_month: created_at_month) do
    Product.rummage(%{
      search: %{created_at_month: %{assoc: [], search_term: created_at_month, search_type: :eq}},
      sort: %{assoc: [], field: :price, order: :asc},
      paginate: @paginate})
  end

  def list_products_query(category_name: category_name) do
    Product.rummage(%{
      search: %{category_name: category_name},
      sort: %{assoc: [], field: :price, order: :asc},
      paginate: @paginate})
  end
end

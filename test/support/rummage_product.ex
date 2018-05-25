defmodule Rummage.Ecto.Rummage.Product do
  use Rummage.Schema,
    paginate: Rummage.Ecto.Rummage.Paginate,
    sort: Rummage.Ecto.Rummage.Product.Sort,
    search: Rummage.Ecto.Rummage.Product.Search,
    schema: Rummage.Ecto.Product
end

defmodule Rummage.Ecto.Rummage.Paginate do
  use Rummage.Schema.Paginate
end

defmodule Rummage.Ecto.Rummage.Product.Sort do
  use Rummage.Schema.Sort,
    default_name: "inserted_at",
    handlers: [
      category_name: %{field: :name, assoc: [inner: :category], ci: true},
      name: %{ci: true},
      price: %{},
    ]

  def sort(query, "inserted_at", order) do
    order = String.to_atom(order)

    from p in query,
      order_by: [
        {^order, p.inserted_at},
        {^order, p.id}
      ]
  end

  # Because we're overriding sort we need to call super...
  def sort(query, name, order) do
    super(query, name, order)
  end
end

defmodule Rummage.Ecto.Rummage.Product.Search do
  use Rummage.Schema.Search,
    handlers: [
      category_name: %{search_field: :name, search_type: :like, assoc: [inner: :category]},
      price_gteq: %{search_field: :price, search_type: :gteq, type: :float},
      price_lteq: %{search_field: :price, search_type: :lteq, type: :float},
      name: %{search_type: :like},
      month: :integer,
      year: :integer,
    ]

  # Skip blank searches
  def search(query, _name, nil), do: query
  def search(query, _name, ""), do: query

  def search(query, :month, month) do
    from p in query,
      where: fragment("date_part('month', ?)", p.inserted_at) == ^month
  end

  def search(query, :year, year) do
    from p in query,
      where: fragment("date_part('year', ?)", p.inserted_at) == ^year
  end

  # Because we're overriding search we need to call super...
  def search(query, name, value) do
    super(query, name, value)
  end
end

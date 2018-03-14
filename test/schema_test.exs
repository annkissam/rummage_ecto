defmodule Rummage.SchemaTest do
  use ExUnit.Case
  doctest Rummage.Schema

  alias Rummage.Ecto.Repo
  alias Rummage.Ecto.Product
  alias Rummage.Ecto.Category

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  defp create_categories_and_products() do
    for x <- 1..4 do
      parent_category = %Category{category_name: "Parent Category #{10 - x}"}
        |> Repo.insert!

      category = %Category{category_name: "Category #{x}", category: parent_category}
        |> Repo.insert!

      for y <- 1..2 do
        %Product{
          name: "Product #{x}-#{y}",
          price: 10.0 * x,
          category: category
        } |> Repo.insert!
      end
    end
  end

  test "opts: query" do
  end

  test "opts: preload" do
  end

  test "default paginate, sort, or search" do
    create_categories_and_products()

    params = %{}

    {rummage, products} = Rummage.Ecto.Rummage.Product.rummage(params)

    assert length(products) == 2
    assert Enum.map(products, &(&1.name)) == ["Product 1-1", "Product 1-2"]

    assert rummage.changeset.changes.paginate.changes == %{per_page: 2}
    assert rummage.changeset.changes.paginate.data == %Rummage.Ecto.Rummage.Paginate{}
    assert rummage.changeset.changes.paginate.params == %{}

    assert rummage.changeset.changes.search.changes == %{}
    assert rummage.changeset.changes.search.data == %Rummage.Ecto.Rummage.Product.Search{}
    assert rummage.changeset.changes.search.params == %{}

    assert rummage.changeset.changes.sort.changes == %{name: "inserted_at", order: "asc"}
    assert rummage.changeset.changes.sort.data == %Rummage.Ecto.Rummage.Product.Sort{}
    assert rummage.changeset.changes.sort.params == %{}

    assert rummage.changeset.data == %Rummage.Ecto.Rummage.Product{}
    assert rummage.changeset.params == %{"paginate" => %{}, "search" => %{}, "sort" => %{}}

    assert rummage.params == %{
      paginate: %{page: 1, per_page: 2},
      search: %{category_name: nil, month: nil, name: nil, price_gteq: nil, price_lteq: nil, year: nil},
      sort: %{name: "inserted_at", order: "asc"}
    }

    assert rummage.paginate == %Rummage.Ecto.Rummage.Paginate{max_page: 4, page: 1, per_page: 2, total_count: 8}

    assert rummage.search == %Rummage.Ecto.Rummage.Product.Search{category_name: nil, month: nil, name: nil, price_gteq: nil, price_lteq: nil, year: nil}

    assert rummage.sort == %Rummage.Ecto.Rummage.Product.Sort{name: "inserted_at", order: "asc"}
  end

  test "paginate" do
    create_categories_and_products()

    params = %{"paginate" => %{"page" => 2, "per_page" => 4}}

    {rummage, products} = Rummage.Ecto.Rummage.Product.rummage(params)

    assert length(products) == 4
    assert Enum.map(products, &(&1.name)) == ["Product 3-1", "Product 3-2", "Product 4-1", "Product 4-2"]

    assert rummage.changeset.changes.paginate.changes == %{per_page: 4, page: 2}
    assert rummage.changeset.changes.paginate.data == %Rummage.Ecto.Rummage.Paginate{}
    assert rummage.changeset.changes.paginate.params == %{"page" => 2, "per_page" => 4}

    assert rummage.changeset.changes.search.changes == %{}
    assert rummage.changeset.changes.search.data == %Rummage.Ecto.Rummage.Product.Search{}
    assert rummage.changeset.changes.search.params == %{}

    assert rummage.changeset.changes.sort.changes == %{name: "inserted_at", order: "asc"}
    assert rummage.changeset.changes.sort.data == %Rummage.Ecto.Rummage.Product.Sort{}
    assert rummage.changeset.changes.sort.params == %{}

    assert rummage.changeset.data == %Rummage.Ecto.Rummage.Product{}
    assert rummage.changeset.params == %{"paginate" => %{"page" => 2, "per_page" => 4}, "search" => %{}, "sort" => %{}}

    assert rummage.params == %{
      paginate: %{page: 2, per_page: 4},
      search: %{category_name: nil, month: nil, name: nil, price_gteq: nil, price_lteq: nil, year: nil},
      sort: %{name: "inserted_at", order: "asc"}
    }

    assert rummage.paginate == %Rummage.Ecto.Rummage.Paginate{max_page: 2, page: 2, per_page: 4, total_count: 8}

    assert rummage.search == %Rummage.Ecto.Rummage.Product.Search{category_name: nil, month: nil, name: nil, price_gteq: nil, price_lteq: nil, year: nil}

    assert rummage.sort == %Rummage.Ecto.Rummage.Product.Sort{name: "inserted_at", order: "asc"}
  end

  test "sort" do
    create_categories_and_products()

    params = %{"sort" => %{"name" => "name", "order" => "desc"}}

    {rummage, products} = Rummage.Ecto.Rummage.Product.rummage(params)

    assert length(products) == 2
    assert Enum.map(products, &(&1.name)) == ["Product 4-2", "Product 4-1"]

    assert rummage.changeset.changes.paginate.changes == %{per_page: 2}
    assert rummage.changeset.changes.paginate.data == %Rummage.Ecto.Rummage.Paginate{}
    assert rummage.changeset.changes.paginate.params == %{}

    assert rummage.changeset.changes.search.changes == %{}
    assert rummage.changeset.changes.search.data == %Rummage.Ecto.Rummage.Product.Search{}
    assert rummage.changeset.changes.search.params == %{}

    assert rummage.changeset.changes.sort.changes ==  %{name: "name", order: "desc"}
    assert rummage.changeset.changes.sort.data == %Rummage.Ecto.Rummage.Product.Sort{}
    assert rummage.changeset.changes.sort.params == %{"name" => "name", "order" => "desc"}

    assert rummage.changeset.data == %Rummage.Ecto.Rummage.Product{}
    assert rummage.changeset.params == %{"paginate" => %{}, "search" => %{}, "sort" => %{"name" => "name", "order" => "desc"}}

    assert rummage.params == %{
      paginate: %{page: 1, per_page: 2},
      search: %{category_name: nil, month: nil, name: nil, price_gteq: nil, price_lteq: nil, year: nil},
      sort: %{name: "name", order: "desc"}
    }

    assert rummage.paginate == %Rummage.Ecto.Rummage.Paginate{max_page: 4, page: 1, per_page: 2, total_count: 8}

    assert rummage.search == %Rummage.Ecto.Rummage.Product.Search{category_name: nil, month: nil, name: nil, price_gteq: nil, price_lteq: nil, year: nil}

    assert rummage.sort == %Rummage.Ecto.Rummage.Product.Sort{name: "name", order: "desc"}
  end

  test "search" do
    create_categories_and_products()

    params = %{"search" => %{"name" => "3-"}}

    {rummage, products} = Rummage.Ecto.Rummage.Product.rummage(params)

    assert length(products) == 2
    assert Enum.map(products, &(&1.name)) == ["Product 3-1", "Product 3-2"]

    assert rummage.changeset.changes.paginate.changes == %{per_page: 2}
    assert rummage.changeset.changes.paginate.data == %Rummage.Ecto.Rummage.Paginate{}
    assert rummage.changeset.changes.paginate.params == %{}

    assert rummage.changeset.changes.search.changes == %{name: "3-"}
    assert rummage.changeset.changes.search.data == %Rummage.Ecto.Rummage.Product.Search{}
    assert rummage.changeset.changes.search.params == %{"name" => "3-"}

    assert rummage.changeset.changes.sort.changes == %{name: "inserted_at", order: "asc"}
    assert rummage.changeset.changes.sort.data == %Rummage.Ecto.Rummage.Product.Sort{}
    assert rummage.changeset.changes.sort.params == %{}

    assert rummage.changeset.data == %Rummage.Ecto.Rummage.Product{}
    assert rummage.changeset.params == %{"paginate" => %{}, "search" => %{"name" => "3-"}, "sort" => %{}}

    assert rummage.params == %{
      paginate: %{page: 1, per_page: 2},
      search: %{category_name: nil, month: nil, name: "3-", price_gteq: nil, price_lteq: nil, year: nil},
      sort: %{name: "inserted_at", order: "asc"}
    }

    assert rummage.paginate == %Rummage.Ecto.Rummage.Paginate{page: 1, per_page: 2, max_page: 1, total_count: 2}

    assert rummage.search == %Rummage.Ecto.Rummage.Product.Search{category_name: nil, month: nil, name: "3-", price_gteq: nil, price_lteq: nil, year: nil}

    assert rummage.sort == %Rummage.Ecto.Rummage.Product.Sort{name: "inserted_at", order: "asc"}
  end

  test "search & sort & pagainte" do
    create_categories_and_products()

    params = %{
      "search" => %{"name" => "-2"},
      "sort" => %{"name" => "name", "order" => "desc"},
      "paginate" => %{"page" => 1, "per_page" => 3},
    }

    {rummage, products} = Rummage.Ecto.Rummage.Product.rummage(params)

    assert length(products) == 3
    assert Enum.map(products, &(&1.name)) == ["Product 4-2", "Product 3-2", "Product 2-2"]

    assert rummage.changeset.changes.paginate.changes == %{per_page: 3}
    assert rummage.changeset.changes.paginate.data == %Rummage.Ecto.Rummage.Paginate{}
    assert rummage.changeset.changes.paginate.params == %{"page" => 1, "per_page" => 3}

    assert rummage.changeset.changes.search.changes == %{name: "-2"}
    assert rummage.changeset.changes.search.data == %Rummage.Ecto.Rummage.Product.Search{}
    assert rummage.changeset.changes.search.params == %{"name" => "-2"}

    assert rummage.changeset.changes.sort.changes == %{name: "name", order: "desc"}
    assert rummage.changeset.changes.sort.data == %Rummage.Ecto.Rummage.Product.Sort{}
    assert rummage.changeset.changes.sort.params == %{"name" => "name", "order" => "desc"}

    assert rummage.changeset.data == %Rummage.Ecto.Rummage.Product{}
    assert rummage.changeset.params == %{"paginate" => %{"page" => 1, "per_page" => 3}, "search" => %{"name" => "-2"}, "sort" => %{"name" => "name", "order" => "desc"}}

    assert rummage.params == %{
      paginate: %{page: 1, per_page: 3},
      search: %{category_name: nil, month: nil, name: "-2", price_gteq: nil, price_lteq: nil, year: nil},
      sort: %{name: "name", order: "desc"}
    }

    assert rummage.paginate == %Rummage.Ecto.Rummage.Paginate{page: 1, max_page: 2, per_page: 3, total_count: 4}

    assert rummage.search == %Rummage.Ecto.Rummage.Product.Search{category_name: nil, month: nil, name: "-2", price_gteq: nil, price_lteq: nil, year: nil}

    assert rummage.sort == %Rummage.Ecto.Rummage.Product.Sort{name: "name", order: "desc"}
  end

  test "nil paginate, sort, or search" do
    create_categories_and_products()

    params = %{
      "search" => nil,
      "sort" => nil,
      "paginate" => nil
    }

    {rummage, products} = Rummage.Ecto.Rummage.Product.rummage(params)

    assert length(products) == 8
    assert Enum.map(products, &(&1.name)) |> Enum.sort() == ["Product 1-1", "Product 1-2", "Product 2-1", "Product 2-2", "Product 3-1", "Product 3-2", "Product 4-1", "Product 4-2"]

    assert rummage.changeset.changes == %{}
    assert rummage.changeset.data == %Rummage.Ecto.Rummage.Product{}
    assert rummage.changeset.params == %{"paginate" => nil, "search" => nil, "sort" => nil}

    assert rummage.params == %{paginate: nil, search: nil, sort: nil}

    assert rummage.paginate == nil

    assert rummage.search == nil

    assert rummage.sort == nil
  end
end

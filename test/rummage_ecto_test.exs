defmodule Rummage.EctoTest do
  use ExUnit.Case
  doctest Rummage.Ecto

  alias Rummage.Ecto.Repo
  alias Rummage.Ecto.Product
  alias Rummage.Ecto.Category

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  defp create_categories_and_products() do
    for x <- 1..4 do
      parent_category = %Category{name: "Parent Category #{10 - x}"}
        |> Repo.insert!

      category = %Category{name: "Category #{x}", parent_category: parent_category}
        |> Repo.insert!

      for y <- 1..2 do
        %Product{
          internal_code: "#{x}->#{y}",
          name: "Product #{y}->#{x}",
          price: 10.0 * x,
          category: category
        } |> Repo.insert!
      end
    end
  end

  test "rummage call with paginate returns the correct results for Product" do
    create_categories_and_products()

    rummage = %{paginate: %{page: 2}}

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 1

    # Test rummage params
    assert rummage == %{
      paginate: %{per_page: 1, page: 2, max_page: 8, total_count: 8}
    }
  end

  test "rummage call with paginate returns the correct results for Category" do
    create_categories_and_products()

    rummage = %{paginate: %{page: 2}}

    {queryable, rummage} = Category.rummage(rummage, per_page: 3)

    categories = Repo.all(queryable)

    # Test length
    assert length(categories) == 3

    # Test rummage params
    assert rummage == %{
      paginate: %{per_page: 3, page: 2, max_page: 3, total_count: 8},
    }
  end

  test "rummage call with sort without assoc params returns the correct results" do
    create_categories_and_products()

    rummage = %{sort: %{field: :name, order: :asc}}

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 8

    # Test ordering
    assert Enum.map(products, & &1.name) == ["Product 1->1", "Product 1->2",
                                             "Product 1->3", "Product 1->4",
                                             "Product 2->1", "Product 2->2",
                                             "Product 2->3", "Product 2->4"]

    # Test rummage params
    assert rummage == %{sort: %{assoc: [], field: :name, order: :asc}}
  end

  test "rummage call with sort and assoc params returns the correct results" do
    create_categories_and_products()

    rummage = %{
      "sort" => %{"assoc" => ["category"], "field" => "name.asc"}
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 8

    # Test ordering
    [products_1, products_2, products_3, products_4] = Enum.chunk(products, 2)

    assert Enum.all?(Repo.preload(products_1, :category), & &1.category.name == "Category 1")
    assert Enum.all?(Repo.preload(products_2, :category), & &1.category.name == "Category 2")
    assert Enum.all?(Repo.preload(products_3, :category), & &1.category.name == "Category 3")
    assert Enum.all?(Repo.preload(products_4, :category), & &1.category.name == "Category 4")

    # Test rummage params
    assert rummage == %{
      "sort" => %{"assoc" => ["category"], "field" => "name.asc"}
    }
  end

  test "rummage call with search and search_type lteq returns the correct results" do
    create_categories_and_products()

    rummage = %{search: %{price: %{search_type: :lteq, search_term: 10}}}

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test prices of products
    assert Enum.all?(products, & &1.price <= 10.0)

    # Test rummage params
    assert rummage == %{
      search: %{price: %{search_type: :lteq, search_term: 10,
        search_expr: :where, assoc: []}}
    }
  end

  test "rummage call with search and search_type eq returns the correct results" do
    create_categories_and_products()

    rummage = %{search: %{price: %{search_type: :eq, search_term: 10}}}

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test prices of products
    assert Enum.all?(products, & &1.price <= 10.0)

    # Test rummage params
    assert rummage == %{
      search: %{price: %{search_type: :eq, search_term: 10, assoc: [],
        search_expr: :where}}
    }
  end

  test "rummage call with search and search_type gteq returns the correct results" do
    create_categories_and_products()

    rummage = %{
      search: %{price: %{search_type: :gteq, search_term: 10}}
    }

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 8

    # Test prices of products
    assert Enum.all?(products, & &1.price >= 10.0)

    # Test rummage params
    assert rummage == %{
      search: %{price: %{search_type: :gteq, search_term: 10, assoc: [],
        search_expr: :where}}
    }
  end

  test "rummage call with search and assoc params returns the correct results" do
    create_categories_and_products()

    rummage = %{
      search: %{name: %{assoc: [inner: :category], search_type: :like,
        search_term: "1"}}
    }

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test prices of products
    assert Enum.all?(Repo.preload(products, :category), & &1.category.name == "Category 1")

    # Test rummage params
    assert rummage == %{
      search: %{name: %{assoc: [inner: :category], search_type: :like,
        search_term: "1", search_expr: :where}}
    }
  end

  test "rummage call with search, sort and paginate" do
    create_categories_and_products()

    rummage = %{
      paginate: %{page: 2, per_page: 2},
      search: %{price: %{search_type: :lteq, search_term: 10}},
      sort: %{field: :name, order: :asc},
    }

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    # Test length
    assert Enum.empty?(products)

    assert Enum.all?(products, & &1.price <= 10)

    # Test prices of products
    # assert Enum.all?(Repo.preload(products, :category), & &1.category.name == "Category 1")

    # Test rummage params
    assert rummage == %{
      search: %{price: %{search_type: :lteq, search_term: 10, assoc: [],
        search_expr: :where}},
      sort: %{field: :name, order: :asc, assoc: []},
      paginate: %{per_page: 2, page: 2, max_page: 4, total_count: 8},
    }
  end

  test "rummage call with assocs search, assoc sort and paginate" do
    create_categories_and_products()

    rummage = %{
      paginate: %{page: 1, per_page: 2},
      search: %{name: %{assoc: [inner: :category], search_type: :like,
        search_term: "1"}},
      sort: %{assoc: [inner: :category], field: :name, order: :asc}
    }

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test search
    assert Enum.all?(Repo.preload(products, :category), & &1.category.name == "Category 1")

    # Test rummage params
    assert rummage == %{
      search: %{name: %{assoc: [inner: :category], search_term: "1",
        search_type: :like, search_expr: :where}},
      sort: %{field: :name, order: :asc, assoc: [inner: :category]},
      paginate: %{per_page: 2, page: 1, max_page: 4, total_count: 8}
    }
  end

  test "rummage call with multiple associations in assocs search" do
    create_categories_and_products()

    rummage = %{
      paginate: %{page: 1},
      search: %{name: %{assoc: [{:inner, :category}, {:inner, :parent_category}],
        search_type: :like, search_term: "Parent"}},
      sort: %{assoc: [{:inner, :category}], field: :name, order: :asc}
    }

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 1

    # Test search
    assert Enum.all?(Repo.preload(products, :category), & Repo.preload(&1.category, :parent_category).parent_category.name =~ "Parent Category")

    # Test sort
    assert Enum.all?(Repo.preload(products, :category), & &1.category.name == "Category 1")
    assert Enum.all?(Repo.preload(products, :category), & Repo.preload(&1.category, :parent_category).parent_category.name == "Parent Category 9")

    # Test rummage params
    assert rummage == %{
      search: %{name: %{assoc: [inner: :category, inner: :parent_category],
        search_term: "Parent", search_type: :like, search_expr: :where}},
      sort: %{field: :name, order: :asc, assoc: [inner: :category]},
      paginate: %{
        per_page: 1,
        page: 1,
        max_page: 8,
        total_count: 8,
      },
    }
  end

  test "rummage call with multiple associations in assocs search and assoc sort" do
    create_categories_and_products()

    rummage = %{
      paginate: %{page: 1, per_page: 2},
      search: %{name: %{assoc: [inner: :category, inner: :parent_category],
        search_type: :like, search_term: "Parent"}},
      sort: %{assoc: [inner: :category, inner: :parent_category],
        field: :name, order: :asc}
    }

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test search
    assert Enum.all?(Repo.preload(products, :category), & Repo.preload(&1.category, :parent_category).parent_category.name =~ "Parent Category")

    # Test sort
    assert Enum.all?(Repo.preload(products, :category), & &1.category.name == "Category 4")
    assert Enum.all?(Repo.preload(products, :category), & Repo.preload(&1.category, :parent_category).parent_category.name == "Parent Category 6")

    # Test rummage params
    assert rummage == %{
      search: %{name: %{assoc: [inner: :category, inner: :parent_category],
        search_term: "Parent", search_type: :like, search_expr: :where}},
      sort: %{field: :name, order: :asc,
        assoc: [inner: :category, inner: :parent_category]},
      paginate: %{per_page: 2, page: 1, max_page: 4, total_count: 8},
    }
  end

  test "rummage call with multiple associations in assocs sort" do
    create_categories_and_products()

    rummage = %{
      paginate: %{page: 1},
      search: %{name: %{assoc: [{:inner, :category}],
        search_type: :like, search_term: "Category"}},
      sort: %{assoc: [{:inner, :category}, {:inner, :parent_category}],
        field: :name, order: :asc}
    }

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 1

    # Test search
    assert Enum.all?(Repo.preload(products, :category), & &1.category.name =~ "Category")

    # Test sort
    assert Enum.all?(Repo.preload(products, :category), & &1.category.name =~ "Category 4")
    assert Enum.all?(Repo.preload(products, :category), & Repo.preload(&1.category, :parent_category).parent_category.name == "Parent Category 6")

    # Test rummage params
    assert rummage == %{
      search: %{name: %{assoc: [inner: :category],
        search_term: "Category", search_type: :like, search_expr: :where}},
      sort: %{field: :name, order: :asc,
        assoc: [inner: :category, inner: :parent_category]},
      paginate: %{per_page: 1, page: 1, max_page: 8, total_count: 8}
    }
  end

  test "rummage call with search scope" do
    create_categories_and_products()

    rummage = %{search: %{category_name: "Category 1"}}

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    assert length(products) == 2

    assert Enum.map(products, & &1.name) == ["Product 2->1", "Product 1->1"]

    rummage = %{search: %{invalid_scope: "Category 1"}}

    assert_raise RuntimeError, ~r/No scope `invalid_scope`/, fn ->
      Product.rummage(rummage)
    end
  end

  test "rummage call with sort scope" do
    create_categories_and_products()

    rummage = %{sort: {:category_name, :asc}}

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    assert length(products) == 8

    assert (products |> Enum.map(& &1.name) |> Enum.sort()) ==
      Enum.sort(
                ["Product 2->1", "Product 1->1",
                 "Product 2->2", "Product 1->2",
                 "Product 2->3", "Product 1->3",
                 "Product 2->4", "Product 1->4"]
                )
    rummage = %{sort: {:invalid_scope, :asc}}

    assert_raise RuntimeError, ~r/No scope `invalid_scope`/, fn ->
      Product.rummage(rummage)
    end
  end

  test "rummage call with paginate scope" do
    create_categories_and_products()

    rummage = %{paginate: {:category_show, 1}}

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    assert length(products) == 5

    assert Enum.map(products, & &1.name) == ["Product 1->1", "Product 2->1",
                                             "Product 1->2", "Product 2->2",
                                             "Product 1->3"]
    rummage = %{paginate: {:invalid_scope, 5}}

    assert_raise RuntimeError, ~r/No scope `invalid_scope`/, fn ->
      Product.rummage(rummage)
    end
  end

  test "rummage call with custom search scope" do
    create_categories_and_products()

    rummage = %{search: %{category_quarter: Float.ceil(Date.utc_today().month / 3)}}

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    assert length(products) == 8

    assert Enum.map(products, & &1.name) == ["Product 2->1", "Product 1->1",
                                             "Product 2->2", "Product 1->2",
                                             "Product 2->3", "Product 1->3",
                                             "Product 2->4", "Product 1->4"]

    rummage = %{search: %{invalid_scope: "Category 1"}}

    assert_raise RuntimeError, ~r/No scope `invalid_scope`/, fn ->
      Product.rummage(rummage)
    end
  end

  test "rummage call with custom sort scope" do
    create_categories_and_products()

    rummage = %{sort: {:category_microseconds, :desc}}

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    assert length(products) == 8

    assert (products |> Enum.map(& &1.name) |> Enum.sort()) ==
      Enum.sort(
                ["Product 2->1", "Product 1->1",
                 "Product 2->2", "Product 1->2",
                 "Product 2->3", "Product 1->3",
                 "Product 2->4", "Product 1->4"]
                )

    rummage = %{sort: {:category_milliseconds, :desc}}

    assert_raise RuntimeError, ~r/No scope `category_milliseconds`/, fn ->
      Product.rummage(rummage)
    end
  end

  test "rummage call with custom paginte scope" do
    create_categories_and_products()

    rummage = %{paginate: {:small_page, 1}}

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    assert length(products) == 5

    assert Enum.map(products, & &1.name) == ["Product 1->1", "Product 2->1",
                                             "Product 1->2", "Product 2->2",
                                             "Product 1->3"]

    rummage = %{paginate: {:category_milliseconds, 1}}

    assert_raise RuntimeError, ~r/No scope `category_milliseconds`/, fn ->
      Product.rummage(rummage)
    end
  end

  test "rummage call with rummage_field for search" do
    create_categories_and_products()

    rummage = %{search: %{created_at_year: %{search_type: :eq, search_term: Date.utc_today.year}}}

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    assert length(products) == 8

    assert Enum.map(products, & &1.name) == ["Product 1->1", "Product 2->1",
                                             "Product 1->2", "Product 2->2",
                                             "Product 1->3", "Product 2->3",
                                             "Product 1->4", "Product 2->4"]
  end

  test "rummage call with rummage_field for sort" do
    create_categories_and_products()

    rummage = %{sort: %{field: :created_at_year, order: :asc}}

    {queryable, rummage} = Product.rummage(rummage)

    products = Repo.all(queryable)

    assert length(products) == 8

    assert Enum.map(products, & &1.name) == ["Product 1->1", "Product 2->1",
                                             "Product 1->2", "Product 2->2",
                                             "Product 1->3", "Product 2->3",
                                             "Product 1->4", "Product 2->4"]
  end
end

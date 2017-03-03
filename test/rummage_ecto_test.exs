defmodule Rummage.EctoTest do
  use ExUnit.Case
  doctest Rummage.Ecto

  alias Rummage.Ecto.Repo
  alias Rummage.Ecto.Product
  alias Rummage.Ecto.Category

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Rummage.Ecto.Repo)
  end

  defp create_categories_and_products do
    for x <- 1..4 do
      category = %Category{category_name: "Category #{x}"}
      |> Repo.insert!

      for x <- 1..2 do
        %Product{
          name: "Product #{x}",
          price: 10.0 * x,
          category_id: category.id
        } |> Repo.insert!
      end
    end
  end

  test "default_per_page for Product returns the default_per_page setup in the config (2)" do
    assert Product.default_per_page == "2"
  end

  test "default_per_page for Category returns the per_page in the use call (10)" do
    assert Category.default_per_page == "3"
  end

  test "rummage call with paginate returns the correct results for Product" do
    create_categories_and_products

    rummage = %{
      "paginate" => %{
        "page" => "2",
      },
    }

    {queryable, rummage} = Product.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test rummage params
    assert rummage == %{
      "paginate" => %{
        "per_page" => "2",
        "page" => "2",
        "max_page" => "4",
        "total_count" => "8",
      },
    }
  end

  test "rummage call with paginate returns the correct results for Category" do
    create_categories_and_products

    rummage = %{
      "paginate" => %{
        "page" => "1",
      },
    }

    {queryable, rummage} = Category.rummage(Category, rummage)

    categories = Repo.all(queryable)

    # Test length
    assert length(categories) == 3

    # Test rummage params
    assert rummage == %{
      "paginate" => %{
        "per_page" => "3",
        "page" => "1",
        "max_page" => "2",
        "total_count" => "4",
      },
    }
  end

  test "rummage call with sort without assoc params returns the correct results" do
    create_categories_and_products

    rummage = %{
      "sort" => ["name.asc"]
    }

    {queryable, rummage} = Product.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 8

    # Test ordering
    {products_1, products_2} = Enum.split(products, 4)

    assert Enum.all?(products_1, & &1.name == "Product 1")
    assert Enum.all?(products_2, & &1.name == "Product 2")

    # Test rummage params
    assert rummage == %{
      "sort" => ["name.asc"]
    }
  end

  test "rummage call with sort and assoc params returns the correct results" do
    create_categories_and_products

    rummage = %{
      "sort" => [["category"], "category_name.asc"]
    }

    {queryable, rummage} = Product.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 8

    # Test ordering
    [products_1, products_2, products_3, products_4] = Enum.chunk(products, 2)

    assert Enum.all?(Repo.preload(products_1, :category), & &1.category.category_name == "Category 1")
    assert Enum.all?(Repo.preload(products_2, :category), & &1.category.category_name == "Category 2")
    assert Enum.all?(Repo.preload(products_3, :category), & &1.category.category_name == "Category 3")
    assert Enum.all?(Repo.preload(products_4, :category), & &1.category.category_name == "Category 4")

    # Test rummage params
    assert rummage == %{
      "sort" => [["category"], "category_name.asc"]
    }
  end

  test "rummage call with search and search_type lteq returns the correct results" do
    create_categories_and_products

    rummage = %{
      "search" => %{"price" => ["lteq", 10]}
    }

    {queryable, rummage} = Product.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 4

    # Test prices of products
    assert Enum.all?(products, & &1.price <= 10.0)

    # Test rummage params
    assert rummage == %{
      "search" => %{"price" => ["lteq", 10]}
    }
  end

  test "rummage call with search and search_type eq returns the correct results" do
    create_categories_and_products

    rummage = %{
      "search" => %{"price" => ["eq", 10]}
    }

    {queryable, rummage} = Product.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 4

    # Test prices of products
    assert Enum.all?(products, & &1.price <= 10.0)

    # Test rummage params
    assert rummage == %{
      "search" => %{"price" => ["eq", 10]}
    }
  end

  test "rummage call with search and search_type gteq returns the correct results" do
    create_categories_and_products

    rummage = %{
      "search" => %{"price" => ["gteq", 10]}
    }

    {queryable, rummage} = Product.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 8

    # Test prices of products
    assert Enum.all?(products, & &1.price >= 10.0)

    # Test rummage params
    assert rummage == %{
      "search" => %{"price" => ["gteq", 10]}
    }
  end

  test "rummage call with search and assoc params returns the correct results" do
    create_categories_and_products

    rummage = %{
      "search" => %{"category_name" => [["category"], "like", "1"]}
    }

    {queryable, rummage} = Product.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test prices of products
    assert Enum.all?(Repo.preload(products, :category), & &1.category.category_name == "Category 1")

    # Test rummage params
    assert rummage == %{
      "search" => %{"category_name" => [["category"], "like", "1"]}
    }
  end
end

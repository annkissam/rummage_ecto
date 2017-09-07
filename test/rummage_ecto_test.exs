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
      parent_category = %Category{category_name: "Parent Category #{10 - x}"}
        |> Repo.insert!

      category = %Category{category_name: "Category #{x}", category: parent_category}
        |> Repo.insert!

      for x <- 1..2 do
        %Product{
          name: "Product #{x}",
          price: 10.0 * x,
          category: category
        } |> Repo.insert!
      end
    end
  end

  test "rummage call with paginate returns the correct results for Product" do
    create_categories_and_products()

    rummage = %{
      "paginate" => %{
        "page" => 2,
      },
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test rummage params
    assert rummage == %{
      "paginate" => %{
        "per_page" => 2,
        "page" => 2,
        "max_page" => 4,
        "total_count" => 8,
      },
    }
  end

  test "rummage call with paginate returns the correct results for Category" do
    create_categories_and_products()

    rummage = %{
      "paginate" => %{
        "page" => 1,
      },
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Category, rummage, per_page: 3)

    categories = Repo.all(queryable)

    # Test length
    assert length(categories) == 3

    # Test rummage params
    assert rummage == %{
      "paginate" => %{
        "per_page" => 3,
        "page" => 1,
        "max_page" => 3,
        "total_count" => 8,
      },
    }
  end

  test "rummage call with sort without assoc params returns the correct results" do
    create_categories_and_products()

    rummage = %{
      "sort" => %{"field" => "name.asc"}
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 8

    # Test ordering
    {products_1, products_2} = Enum.split(products, 4)

    assert Enum.all?(products_1, & &1.name == "Product 1")
    assert Enum.all?(products_2, & &1.name == "Product 2")

    # Test rummage params
    assert rummage == %{
      "sort" => %{"field" => "name.asc"}
    }
  end

  test "rummage call with sort and assoc params returns the correct results" do
    create_categories_and_products()

    rummage = %{
      "sort" => %{"assoc" => ["category"], "field" => "category_name.asc"}
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

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
      "sort" => %{"assoc" => ["category"], "field" => "category_name.asc"}
    }
  end

  test "rummage call with search and search_type lteq returns the correct results" do
    create_categories_and_products()

    rummage = %{
      "search" => %{"price" => %{"search_type" => "lteq", "search_term" => 10}}
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 4

    # Test prices of products
    assert Enum.all?(products, & &1.price <= 10.0)

    # Test rummage params
    assert rummage == %{
      "search" => %{"price" => %{"search_type" => "lteq", "search_term" => 10}}
    }
  end

  test "rummage call with search and search_type eq returns the correct results" do
    create_categories_and_products()

    rummage = %{
      "search" => %{"price" => %{"search_type" => "eq", "search_term" => 10}}
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 4

    # Test prices of products
    assert Enum.all?(products, & &1.price <= 10.0)

    # Test rummage params
    assert rummage == %{
      "search" => %{"price" => %{"search_type" => "eq", "search_term" => 10}}
    }
  end

  test "rummage call with search and search_type gteq returns the correct results" do
    create_categories_and_products()

    rummage = %{
      "search" => %{"price" => %{"search_type" => "gteq", "search_term" => 10}}
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 8

    # Test prices of products
    assert Enum.all?(products, & &1.price >= 10.0)

    # Test rummage params
    assert rummage == %{
      "search" => %{"price" => %{"search_type" => "gteq", "search_term" => 10}}
    }
  end

  test "rummage call with search and assoc params returns the correct results" do
    create_categories_and_products()

    rummage = %{
      "search" => %{"category_name" => %{"assoc" => ["category"], "search_type" => "like", "search_term" => "%1%"}}
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test prices of products
    assert Enum.all?(Repo.preload(products, :category), & &1.category.category_name == "Category 1")

    # Test rummage params
    assert rummage == %{
      "search" => %{"category_name" => %{"assoc" => ["category"], "search_type" => "like", "search_term" => "%1%"}}
    }
  end

  test "rummage call with search, sort and paginate" do
    create_categories_and_products()

    rummage = %{
      "paginate" => %{
        "page" => 2,
      },
      "search" => %{"price" => %{"search_type" => "lteq", "search_term" => 10}},
      "sort" => %{"field" => "name.asc"},
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    assert Enum.all?(products, & &1.price <= 10)

    # Test prices of products
    # assert Enum.all?(Repo.preload(products, :category), & &1.category.category_name == "Category 1")

    # Test rummage params
    assert rummage == %{
      "search" => %{"price" => %{"search_type" => "lteq", "search_term" => 10}},
      "sort" => %{"field" => "name.asc"},
      "paginate" => %{
        "per_page" => 2,
        "page" => 2,
        "max_page" => 2,
        "total_count" => 4,
      },
    }
  end

  test "rummage call with assocs search, assoc sort and paginate" do
    create_categories_and_products()

    rummage = %{
      "paginate" => %{
        "page" => 2,
      },
      "search" => %{"category_name" => %{"assoc" => ["category"], "search_type" => "like", "search_term" => "%1%"}},
      "sort" => %{"assoc" => ["category"], "field" => "category_name.asc"}
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test search
    assert Enum.all?(Repo.preload(products, :category), & &1.category.category_name == "Category 1")

    # Test rummage params
    assert rummage == %{
      "search" => %{"category_name" => %{"assoc" => ["category"], "search_term" => "%1%", "search_type" => "like"}},
      "sort" => %{"field" => "category_name.asc", "assoc" => ["category"]},
      "paginate" => %{
        "per_page" => 2,
        "page" => 1,
        "max_page" => 1,
        "total_count" => 2,
      },
    }
  end

  test "rummage call with multiple associations in assocs search" do
    create_categories_and_products()

    rummage = %{
      "paginate" => %{
        "page" => 1,
      },
      "search" => %{"category_name" => %{"assoc" => ["category", "category"], "search_type" => "like", "search_term" => "%Parent%"}},
      "sort" => %{"assoc" => ["category"], "field" => "category_name.asc"}
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test search
    assert Enum.all?(Repo.preload(products, :category), & Repo.preload(&1.category, :category).category.category_name =~ "Parent Category")

    # Test sort
    assert Enum.all?(Repo.preload(products, :category), & &1.category.category_name == "Category 1")
    assert Enum.all?(Repo.preload(products, :category), & Repo.preload(&1.category, :category).category.category_name == "Parent Category 9")

    # Test rummage params
    assert rummage == %{
      "search" => %{"category_name" => %{"assoc" => ["category", "category"], "search_term" => "%Parent%", "search_type" => "like"}},
      "sort" => %{"field" => "category_name.asc", "assoc" => ["category"]},
      "paginate" => %{
        "per_page" => 2,
        "page" => 1,
        "max_page" => 4,
        "total_count" => 8,
      },
    }
  end

  test "rummage call with multiple associations in assocs search and assoc sort" do
    create_categories_and_products()

    rummage = %{
      "paginate" => %{
        "page" => 1,
      },
      "search" => %{"category_name" => %{"assoc" => ["category", "category"], "search_type" => "like", "search_term" => "%Parent%"}},
      "sort" => %{"assoc" => ["category", "category"], "field" => "category_name.asc"}
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test search
    assert Enum.all?(Repo.preload(products, :category), & Repo.preload(&1.category, :category).category.category_name =~ "Parent Category")

    # Test sort
    assert Enum.all?(Repo.preload(products, :category), & &1.category.category_name == "Category 4")
    assert Enum.all?(Repo.preload(products, :category), & Repo.preload(&1.category, :category).category.category_name == "Parent Category 6")

    # Test rummage params
    assert rummage == %{
      "search" => %{"category_name" => %{"assoc" => ["category", "category"], "search_term" => "%Parent%", "search_type" => "like"}},
      "sort" => %{"field" => "category_name.asc", "assoc" => ["category", "category"]},
      "paginate" => %{
        "per_page" => 2,
        "page" => 1,
        "max_page" => 4,
        "total_count" => 8,
      },
    }
  end

  test "rummage call with multiple associations in assocs sort" do
    create_categories_and_products()

    rummage = %{
      "paginate" => %{
        "page" => 1,
      },
      "search" => %{"category_name" => %{"assoc" => ["category"], "search_type" => "like", "search_term" => "%Category%"}},
      "sort" => %{"assoc" => ["category", "category"], "field" => "category_name.asc"}
    }

    {queryable, rummage} = Rummage.Ecto.rummage(Product, rummage)

    products = Repo.all(queryable)

    # Test length
    assert length(products) == 2

    # Test search
    assert Enum.all?(Repo.preload(products, :category), & &1.category.category_name =~ "Category")

    # Test sort
    assert Enum.all?(Repo.preload(products, :category), & &1.category.category_name =~ "Category 4")
    assert Enum.all?(Repo.preload(products, :category), & Repo.preload(&1.category, :category).category.category_name == "Parent Category 6")

    # Test rummage params
    assert rummage == %{
      "search" => %{"category_name" => %{"assoc" => ["category"], "search_term" => "%Category%", "search_type" => "like"}},
      "sort" => %{"field" => "category_name.asc", "assoc" => ["category", "category"]},
      "paginate" => %{
        "per_page" => 2,
        "page" => 1,
        "max_page" => 4,
        "total_count" => 8,
      },
    }
  end
end

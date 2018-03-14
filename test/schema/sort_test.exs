defmodule Rummage.Schema.SortTest do
  use ExUnit.Case
  doctest Rummage.Schema.Sort

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

  test "changeset (default)" do
    params = %{}

    changeset = Rummage.Ecto.Rummage.Product.Sort.changeset(%Rummage.Ecto.Rummage.Product.Sort{}, params)

    assert changeset.changes == %{name: "inserted_at", order: "asc"}
    assert changeset.data == %Rummage.Ecto.Rummage.Product.Sort{}
    assert changeset.params == %{}
  end

  test "changeset" do
    params = %{"name" => "name", "order" => "desc"}

    changeset = Rummage.Ecto.Rummage.Product.Sort.changeset(%Rummage.Ecto.Rummage.Product.Sort{}, params)

    assert changeset.changes == %{name: "name", order: "desc"}
    assert changeset.data == %Rummage.Ecto.Rummage.Product.Sort{}
    assert changeset.params == %{"name" => "name", "order" => "desc"}
  end

  test "rummage" do
    create_categories_and_products()

    params = %Rummage.Ecto.Rummage.Product.Sort{name: "name", order: "desc"}

    products = Rummage.Ecto.Product
    |> Rummage.Ecto.Rummage.Product.Sort.rummage(params)
    |> Repo.all()

    assert length(products) == 8
    assert Enum.map(products, &(&1.name)) == ["Product 4-2", "Product 4-1", "Product 3-2", "Product 3-1", "Product 2-2", "Product 2-1", "Product 1-2", "Product 1-1"]
  end
end

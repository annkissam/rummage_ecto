defmodule Rummage.Ecto.Schema.PaginateTest do
  use ExUnit.Case
  doctest Rummage.Ecto.Schema.Paginate

  alias Rummage.Ecto.Repo
  alias Rummage.Ecto.Product
  alias Rummage.Ecto.Category

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  defp create_categories_and_products() do
    for x <- 1..4 do
      parent_category =
        %Category{name: "Parent Category #{10 - x}"}
        |> Repo.insert!()

      category =
        %Category{name: "Category #{x}", parent_category: parent_category}
        |> Repo.insert!()

      for y <- 1..2 do
        %Product{
          internal_code: "#{x}-#{y}",
          name: "Product #{x}-#{y}",
          price: 10.0 * x,
          category: category
        }
        |> Repo.insert!()
      end
    end
  end

  test "changeset (default)" do
    params = %{}

    changeset = Rummage.Ecto.Rummage.Paginate.changeset(%Rummage.Ecto.Rummage.Paginate{}, params)

    assert changeset.changes == %{per_page: 2}
    assert changeset.data == %Rummage.Ecto.Rummage.Paginate{}
    assert changeset.params == %{}
  end

  test "changeset" do
    params = %{"page" => 2, "per_page" => 4}

    changeset = Rummage.Ecto.Rummage.Paginate.changeset(%Rummage.Ecto.Rummage.Paginate{}, params)

    assert changeset.changes == %{per_page: 4, page: 2}
    assert changeset.data == %Rummage.Ecto.Rummage.Paginate{}
    assert changeset.params == %{"page" => 2, "per_page" => 4}
  end

  test "rummage" do
    create_categories_and_products()

    params = %Rummage.Ecto.Rummage.Paginate{page: 2, per_page: 4}

    {query, paginate} =
      Rummage.Ecto.Product
      |> Rummage.Ecto.Rummage.Paginate.rummage(params)

    products = Repo.all(query)

    assert length(products) == 4

    assert Enum.map(products, & &1.name) == [
             "Product 3-1",
             "Product 3-2",
             "Product 4-1",
             "Product 4-2"
           ]

    assert paginate == %Rummage.Ecto.Rummage.Paginate{
             max_page: 2,
             page: 2,
             per_page: 4,
             total_count: 8
           }
  end
end

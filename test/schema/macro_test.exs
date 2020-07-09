defmodule Rummage.Ecto.Schema.MacroTest do
  use ExUnit.Case

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

    changeset = Rummage.Ecto.Rummage.Product.changeset(params)

    assert changeset.changes[:paginate].changes == %{per_page: 2}

    assert changeset.changes[:paginate].data == %Rummage.Ecto.Rummage.Paginate{
             max_page: nil,
             page: 1,
             per_page: nil,
             total_count: nil
           }

    assert changeset.changes[:paginate].params == %{}

    assert changeset.changes[:search].changes == %{}

    assert changeset.changes[:search].data == %Rummage.Ecto.Rummage.Product.Search{
             category_name: nil,
             month: nil,
             name: nil,
             price_gteq: nil,
             price_lteq: nil,
             year: nil
           }

    assert changeset.changes[:search].params == %{}

    assert changeset.changes[:sort].changes == %{name: "inserted_at", order: "asc"}

    assert changeset.changes[:sort].data == %Rummage.Ecto.Rummage.Product.Sort{
             name: nil,
             order: nil
           }

    assert changeset.changes[:sort].params == %{}

    assert changeset.data == %Rummage.Ecto.Rummage.Product{}
    assert changeset.params == %{"paginate" => %{}, "search" => %{}, "sort" => %{}}
  end

  test "changeset" do
    params = %{
      "search" => %{"name" => "3-"},
      "sort" => %{"name" => "name", "order" => "desc"},
      "paginate" => %{"page" => 2, "per_page" => 4}
    }

    changeset = Rummage.Ecto.Rummage.Product.changeset(params)

    assert changeset.changes[:paginate].changes == %{per_page: 4, page: 2}

    assert changeset.changes[:paginate].data == %Rummage.Ecto.Rummage.Paginate{
             max_page: nil,
             page: 1,
             per_page: nil,
             total_count: nil
           }

    assert changeset.changes[:paginate].params == %{"page" => 2, "per_page" => 4}

    assert changeset.changes[:search].changes == %{name: "3-"}

    assert changeset.changes[:search].data == %Rummage.Ecto.Rummage.Product.Search{
             category_name: nil,
             month: nil,
             name: nil,
             price_gteq: nil,
             price_lteq: nil,
             year: nil
           }

    assert changeset.changes[:search].params == %{"name" => "3-"}

    assert changeset.changes[:sort].changes == %{name: "name", order: "desc"}

    assert changeset.changes[:sort].data == %Rummage.Ecto.Rummage.Product.Sort{
             name: nil,
             order: nil
           }

    assert changeset.changes[:sort].params == %{"name" => "name", "order" => "desc"}

    assert changeset.data == %Rummage.Ecto.Rummage.Product{}

    assert changeset.params == %{
             "paginate" => %{"page" => 2, "per_page" => 4},
             "search" => %{"name" => "3-"},
             "sort" => %{"name" => "name", "order" => "desc"}
           }
  end

  test "rummage" do
    create_categories_and_products()

    params = %{
      "search" => %{"name" => "3-"},
      "sort" => %{"name" => "name", "order" => "desc"},
      "paginate" => %{"page" => 1, "per_page" => 4}
    }

    {rummage, products} = Rummage.Ecto.Rummage.Product.rummage(params)

    assert length(products) == 2
    assert Enum.map(products, & &1.name) == ["Product 3-2", "Product 3-1"]

    assert rummage.paginate == %Rummage.Ecto.Rummage.Paginate{
             max_page: 1,
             page: 1,
             per_page: 4,
             total_count: 2
           }

    assert rummage.sort == %Rummage.Ecto.Rummage.Product.Sort{name: "name", order: "desc"}

    assert rummage.search == %Rummage.Ecto.Rummage.Product.Search{
             category_name: nil,
             month: nil,
             name: "3-",
             price_gteq: nil,
             price_lteq: nil,
             year: nil
           }

    assert rummage.params == %{
             paginate: %{page: 1, per_page: 4},
             search: %{
               category_name: nil,
               month: nil,
               name: "3-",
               price_gteq: nil,
               price_lteq: nil,
               year: nil
             },
             sort: %{name: "name", order: "desc"}
           }

    assert rummage.changeset
  end
end

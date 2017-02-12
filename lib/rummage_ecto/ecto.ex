defmodule RummageEcto.Ecto do
  def rummage(query, rummage) when is_nil(rummage) or rummage == %{} do
    rummage = %{"search" => %{},
      "sort"=> [],
      "paginate" => %{"per_page" => RummageEcto.per_page, "page" => "1"}
    }

    query = query
    |> RummageEcto.default_paginate.run(rummage)

    {query, rummage}
  end

  def rummage(query, rummage) do
    query = query
      |> RummageEcto.default_search.run(rummage)
      |> RummageEcto.default_sort.run(rummage)
      |> RummageEcto.default_paginate.run(rummage)

    {query, rummage}
  end
end

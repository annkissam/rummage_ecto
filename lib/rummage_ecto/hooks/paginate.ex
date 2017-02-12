defmodule RummageEcto.Paginate do
  import Ecto.Query

  @behaviour RummageEcto.Hook

  def run(query, rummage) do
    paginate_params = Map.get(rummage, "paginate")

    case paginate_params do
      a when a in [nil, [], ""] -> handle_paginate(query, %{})
      _ -> handle_paginate(query, paginate_params)
    end
  end

  defp handle_paginate(query, paginate_params) do
    per_page = Map.get(paginate_params, "per_page", RummageEcto.per_page)
      |> String.to_integer

    page = Map.get(paginate_params, "page", "1")
      |> String.to_integer

    per_page = if per_page < 1, do: 1, else: per_page
    page = if page < 1, do: 1, else: page

    offset = per_page * (page - 1)

    query
    |> limit(^per_page)
    |> offset(^offset)
  end
end

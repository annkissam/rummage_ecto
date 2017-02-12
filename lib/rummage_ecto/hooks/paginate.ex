defmodule Rummage.Ecto.Hooks.Paginate do
  import Ecto.Query

  @behaviour Rummage.Ecto.Hook

  def run(query, rummage) do
    paginate_params = Map.get(rummage, "paginate")

    case paginate_params do
      a when a in [nil, [], ""] -> handle_paginate(query, %{})
      _ -> handle_paginate(query, paginate_params)
    end
  end

  defp handle_paginate(query, paginate_params) do
    per_page = paginate_params
      |> Map.get("per_page", Rummage.Ecto.per_page)
      |> String.to_integer

    page = paginate_params
      |> Map.get("page", "1")
      |> String.to_integer

    per_page = if per_page < 1, do: 1, else: per_page
    page = if page < 1, do: 1, else: page

    offset = per_page * (page - 1)

    query
    |> limit(^per_page)
    |> offset(^offset)
  end
end

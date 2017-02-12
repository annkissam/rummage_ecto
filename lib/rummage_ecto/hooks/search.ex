defmodule Rummage.Ecto.Hooks.Search do
  import Ecto.Query

  @behaviour Rummage.Ecto.Hook

  def run(query, rummage) do
    search_params = Map.get(rummage, "search")

    case search_params do
      a when a in [nil, [], ""] -> query
      _ -> handle_search(query, search_params)
    end
  end

  defp handle_search(query, search_params) do
    search_params
    |> Map.to_list
    |> Enum.reduce(query, fn(param, q) ->
        field = elem(param, 0)
          |> String.to_atom
        term = elem(param, 1)

        q |> where([b], like(field(b, ^field), ^"%#{String.replace(term, "%", "\\%")}%"))
      end)
  end
end

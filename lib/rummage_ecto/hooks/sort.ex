defmodule RummageEcto.Sort do
  import Ecto.Query

  @behaviour RummageEcto.Hook

  def run(query, rummage) do
    sort_params = Map.get(rummage, "sort")

    case sort_params do
      a when a in [nil, [], ""] -> query
      _ -> handle_sort(query, sort_params)
    end
  end

  defp handle_sort(query, sort_params) do
    order_params =
      Enum.reduce(sort_params, [], fn(unparsed_field, order_params) ->
        cond do
          Regex.match?(~r/\w.asc+$/, unparsed_field) or
            Regex.match?(~r/\w.desc+$/, unparsed_field) ->
              add_order_params(order_params, unparsed_field)
          true -> order_params
        end
      end)

    query |> order_by(^order_params)
  end

  defp add_order_params(order_params, unparsed_field) do
    parsed_field = String.split(unparsed_field, ".")
      |> Enum.drop(-1)
      |> Enum.join(".")
      |> String.to_atom

    order_type = String.split(unparsed_field, ".")
      |> Enum.at(-1)
      |> String.to_atom

    Keyword.put(order_params, order_type, parsed_field)
  end
end

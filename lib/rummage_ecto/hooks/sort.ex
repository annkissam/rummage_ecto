defmodule Rummage.Ecto.Hooks.Sort do
  @moduledoc """
  `Rummage.Ecto.Hooks.Sort` is the default sort hook that comes shipped
  with `Rummage`.

  This module can be overridden with a custom module while using `Rummage.Ecto`
  in `Ecto` struct module.
  """

  import Ecto.Query

  @behaviour Rummage.Ecto.Hook

  @doc """
  Builds a sort query on top of the given `query` from the rummage parameters
  from the given `rummage` struct.

  ## Examples
  When rummage struct passed doesn't have the key "sort", it simply returns the
  query itself:

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> Sort.run(Parent, %{})
      Parent

  When the query passed is not just a struct:

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> query = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex>  Sort.run(query, %{})
      #Ecto.Query<from p in "parents">

  When rummage struct passed has the key "sort", with "field" and "order"
  it returns a sorted version of the query passed in as the argument:

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => "field_1.asc"}
      %{"sort" => "field_1.asc"}
      iex> query = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Sort.run(query, rummage)
      #Ecto.Query<from p in "parents", order_by: [asc: p.field_1]>
  """
  def run(query, rummage) do
    sort_params = Map.get(rummage, "sort")

    case sort_params do
      a when a in [nil, [], ""] -> query
      _ -> handle_sort(query, sort_params)
    end
  end

  defp handle_sort(query, sort_params) do
    order_params = cond do
      Regex.match?(~r/\w.asc+$/, sort_params) or
        Regex.match?(~r/\w.desc+$/, sort_params) ->
          add_order_params([], sort_params)
      true -> []
    end

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

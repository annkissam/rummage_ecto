defmodule Rummage.Ecto.Hooks.Search do
  @moduledoc ~S"""
  `Rummage.Ecto.Hooks.Search` is the default search hook that comes shipped
  with `Rummage`.

  This module can be overridden with a custom module while using `Rummage.Ecto`
  in `Ecto` struct module.
  """

  import Ecto.Query

  @behaviour Rummage.Ecto.Hook

  @doc """
  Builds a search query on top of the given `query` from the rummage parameters
  from the given `rummage` struct.

  ## Examples
  When rummage struct passed doesn't have the key "search", it simply returns the
  query itself:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> Search.run(Parent, %{})
      Parent

  When the query passed is not just a struct:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> query = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex>  Search.run(query, %{})
      #Ecto.Query<from p in "parents">

  When rummage struct passed has the key "search", with "field" and "term"
  it returns a searched version of the query passed in as the argument:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> rummage = %{"search" => %{"field_1" => "field_!"}}
      %{"search" => %{"field_1" => "field_!"}}
      iex> query = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Search.run(query, rummage)
      #Ecto.Query<from p in "parents", where: like(p.field_1, ^"%field_!%")>
  """
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

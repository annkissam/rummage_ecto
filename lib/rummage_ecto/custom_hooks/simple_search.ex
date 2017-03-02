defmodule Rummage.Ecto.CustomHooks.SimpleSearch do
  @moduledoc """
  `Rummage.Ecto.CustomHooks.SimpleSearch` is a custom search hook that comes shipped
  with `Rummage.Ecto`.

  Usage:
  For a regular search:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  searched by ascending `field_1`

  ```elixir
  alias Rummage.Ecto.CustomHooks.SimpleSearch

  searched_queryable = SimpleSearch.run(Parent, %{"search" => %{"field_1" => "field_!"}})
  ```

  For a case-insensitive search:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  searched by ascending case insensitive `field_1`.

  Keep in mind that `case_insensitive` can only be called for `text` fields

  ```elixir
  alias Rummage.Ecto.CustomHooks.SimpleSearch

  searched_queryable = SimpleSearch.run(Parent, %{"search" => %{"field_1.ci" => "field_!"}})
  ```

  This module can be used by overriding the default search module. This can be done
  in the following ways:

  In the `Ecto` module:
  ```elixir
  defmodule SomeModule do
    use Ecto.Schema
    use Rummage.Ecto, search_hook: Rummage.Ecto.CustomHooks.SimpleSearch
  end
  ```

  OR

  Globally for all models in `config.exs` (NOT Recommended):
  ```elixir
  config :rummage_ecto,
    Rummage.Ecto,
    default_search: Rummage.Ecto.CustomHooks.SimpleSearch
  ```
  """

  import Ecto.Query

  @behaviour Rummage.Ecto.Hook

  @doc """
  Builds a search queryable on top of the given `queryable` from the rummage parameters
  from the given `rummage` struct.

  ## Examples
  When rummage struct passed doesn't have the key "search", it simply returns the
  queryable itself:

      iex> alias Rummage.Ecto.CustomHooks.SimpleSearch
      iex> import Ecto.Query
      iex> SimpleSearch.run(Parent, %{})
      Parent

  When the queryable passed is not just a struct:

      iex> alias Rummage.Ecto.CustomHooks.SimpleSearch
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex>  SimpleSearch.run(queryable, %{})
      #Ecto.Query<from p in "parents">

  When rummage `struct` passed has the key `"search"`, but with a value of `%{}`, `""`
  or `[]` it simply returns the `queryable` itself:

      iex> alias Rummage.Ecto.CustomHooks.SimpleSearch
      iex> import Ecto.Query
      iex> SimpleSearch.run(Parent, %{"search" => %{}})
      Parent

      iex> alias Rummage.Ecto.CustomHooks.SimpleSearch
      iex> import Ecto.Query
      iex> SimpleSearch.run(Parent, %{"search" => ""})
      Parent

      iex> alias Rummage.Ecto.CustomHooks.SimpleSearch
      iex> import Ecto.Query
      iex> SimpleSearch.run(Parent, %{"search" => []})
      Parent

  When rummage struct passed has the key "search", with "field" and "term"
  it returns a searched version of the queryable passed in as the argument:

      iex> alias Rummage.Ecto.CustomHooks.SimpleSearch
      iex> import Ecto.Query
      iex> rummage = %{"search" => %{"field_1" => "field_!"}}
      %{"search" => %{"field_1" => "field_!"}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> SimpleSearch.run(queryable, rummage)
      #Ecto.Query<from p in "parents", where: like(p.field_1, ^"%field_!%")>

  When rummage struct passed has case-insensitive search, it returns
  a searched version of the queryable with case_insensitive arguments:

      iex> alias Rummage.Ecto.CustomHooks.SimpleSearch
      iex> import Ecto.Query
      iex> rummage = %{"search" => %{"field_1.ci" => "field_!"}}
      %{"search" => %{"field_1.ci" => "field_!"}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> SimpleSearch.run(queryable, rummage)
      #Ecto.Query<from p in "parents", where: ilike(p.field_1, ^"%field_!%")>
  """
  @spec run(Ecto.Query.t, map) :: {Ecto.Query.t, map}
  def run(queryable, rummage) do
    search_params = Map.get(rummage, "search")

    case search_params do
      a when a in [nil, [], {}, ""] -> queryable
      _ -> handle_search(queryable, search_params)
    end
  end

  defp handle_search(queryable, search_params) do
    search_params
    |> Map.to_list
    |> Enum.reduce(queryable, &search_queryable(&1, &2))
  end

  defp search_queryable(param, queryable) do
    field = param
      |> elem(0)

    case Regex.match?(~r/\w.ci+$/, field) do
      true ->
        field = field
          |> String.split(".")
          |> Enum.drop(-1)
          |> Enum.join(".")
          |> String.to_atom

          term = elem(param, 1)

          queryable
          |> where([b],
            ilike(field(b, ^field), ^"%#{String.replace(term, "%", "\\%")}%"))
      _ ->
        field = String.to_atom(field)

        term = elem(param, 1)

        queryable
        |> where([b],
          like(field(b, ^field), ^"%#{String.replace(term, "%", "\\%")}%"))
    end
  end
end

defmodule Rummage.Ecto.Hooks.Search do
  @moduledoc """
  `Rummage.Ecto.Hooks.Search` is the default search hook that comes shipped
  with `Rummage.Ecto`.

  This module can be overridden with a custom module while using `Rummage.Ecto`
  in `Ecto` struct module.

  Usage:
  For a regular search:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  searched by ascending `field_1`

  ```elixir
  alias Rummage.Ecto.Hooks.Search

  searched_queryable = Search.run(Parent, %{"search" => %{"field_1" => {"like", "field_!"}}}
  ```

  For a case-insensitive search:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  searched by ascending case insensitive `field_1`.

  Keep in mind that `case_insensitive` can only be called for `text` fields

  ```elixir
  alias Rummage.Ecto.Hooks.Search

  searched_queryable = Search.run(Parent, %{"search" => %{"field_1" => {"ilike", "field_!"}}}
  ```

  There are many other `search_types`. Check out `Rummage.Ecto.Services.BuildSearchQuery`'s docs
  to explore more `search_types`

  This module can be overridden with a custom module while using `Rummage.Ecto`
  in `Ecto` struct module:

  In the `Ecto` module:
  ```elixir
  defmodule SomeModule do
    use Ecto.Schema
    use Rummage.Ecto, search_hook: CustomHook
  end
  ```

  OR

  Globally for all models in `config.exs` (NOT Recommended):
  ```elixir
  config :rummage_ecto,
    Rummage.Ecto,
    default_search: CustomHook
  ```

  The `CustomHook` must implement `@behaviour Rummage.Ecto.Hook`. For examples of `CustomHook`, check out some
    `custom_hooks` that are shipped with elixir:

      * `Rummage.Ecto.CustomHooks.SimpleSearch`
      * `Rummage.Ecto.CustomHooks.SimpleSort`
  """

  alias Rummage.Ecto.Services.BuildSearchQuery

  @behaviour Rummage.Ecto.Hook

  @doc """
  Builds a search queryable on top of the given `queryable` from the rummage parameters
  from the given `rummage` struct.

  ## Examples
  When rummage struct passed doesn't have the key "search", it simply returns the
  queryable itself:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> Search.run(Parent, %{})
      Parent

  When the queryable passed is not just a struct:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex>  Search.run(queryable, %{})
      #Ecto.Query<from p in "parents">

  When rummage `struct` passed has the key `"search"`, but with a value of `%{}`, `""`
  or `[]` it simply returns the `queryable` itself:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> Search.run(Parent, %{"search" => %{}})
      Parent

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> Search.run(Parent, %{"search" => ""})
      Parent

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> Search.run(Parent, %{"search" => []})
      Parent

  When rummage `struct` passed has the key "search", with `field`, `search_type` and `term`
  it returns a searched version of the `queryable` passed in as the argument:

  When rummage `struct` passed has `search_type` of `like`, it returns
  a searched version of the `queryable` with `like` search query:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> rummage = %{"search" => %{"field_1" => {"like", "field_!"}}}
      %{"search" => %{"field_1" => {"like", "field_!"}}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Search.run(queryable, rummage)
      #Ecto.Query<from p in "parents", where: like(p.field_1, ^"%field_!%")>

  When rummage `struct` passed has `search_type` of `ilike` (case insensitive), it returns
  a searched version of the `queryable` with `ilike` search query:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> rummage = %{"search" => %{"field_1" => {"ilike", "field_!"}}}
      %{"search" => %{"field_1" => {"ilike", "field_!"}}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Search.run(queryable, rummage)
      #Ecto.Query<from p in "parents", where: ilike(p.field_1, ^"%field_!%")>

  When rummage `struct` passed has `search_type` of `eq`, it returns
  a searched version of the `queryable` with `==` search query:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> rummage = %{"search" => %{"field_1" => {"eq", "field_!"}}}
      %{"search" => %{"field_1" => {"eq", "field_!"}}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Search.run(queryable, rummage)
      #Ecto.Query<from p in "parents", where: p.field_1 == ^"field_!">

  When rummage `struct` passed has `search_type` of `gt`, it returns
  a searched version of the `queryable` with `>` search query:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> rummage = %{"search" => %{"field_1" => {"gt", "field_!"}}}
      %{"search" => %{"field_1" => {"gt", "field_!"}}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Search.run(queryable, rummage)
      #Ecto.Query<from p in "parents", where: p.field_1 > ^"field_!">

  When rummage `struct` passed has `search_type` of `lt`, it returns
  a searched version of the `queryable` with `<` search query:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> rummage = %{"search" => %{"field_1" => {"lt", "field_!"}}}
      %{"search" => %{"field_1" => {"lt", "field_!"}}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Search.run(queryable, rummage)
      #Ecto.Query<from p in "parents", where: p.field_1 < ^"field_!">

  When rummage `struct` passed has `search_type` of `gteq`, it returns
  a searched version of the `queryable` with `>=` search query:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> rummage = %{"search" => %{"field_1" => {"gteq", "field_!"}}}
      %{"search" => %{"field_1" => {"gteq", "field_!"}}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Search.run(queryable, rummage)
      #Ecto.Query<from p in "parents", where: p.field_1 >= ^"field_!">

  When rummage `struct` passed has `search_type` of `lteq`, it returns
  a searched version of the `queryable` with `<=` search query:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> rummage = %{"search" => %{"field_1" => {"lteq", "field_!"}}}
      %{"search" => %{"field_1" => {"lteq", "field_!"}}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Search.run(queryable, rummage)
      #Ecto.Query<from p in "parents", where: p.field_1 <= ^"field_!">
  """
  @spec run(Ecto.Query.t, map) :: {Ecto.Query.t, map}
  def run(queryable, rummage) do
    search_params = Map.get(rummage, "search")

    case search_params do
      a when a in [nil, [], %{}, ""] -> queryable
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
      |> String.to_atom

    search_type = param
      |> elem(1)
      |> elem(0)

    search_term = param
      |> elem(1)
      |> elem(1)

    queryable
    |> BuildSearchQuery.run(field, search_type, search_term)
  end
end

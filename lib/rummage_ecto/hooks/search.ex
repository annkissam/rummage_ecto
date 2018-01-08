defmodule Rummage.Ecto.Hooks.Search do
  @moduledoc """
  TODO: Explain how to use `assoc` better

  `Rummage.Ecto.Hooks.Search` is the default search hook that comes with
  `Rummage.Ecto`.

  This module provides a operations that can add searching functionality to
  a pipeline of `Ecto` queries. This module works by taking fields, and `search_type`,
  `search_term` and `assoc` associated with those `fields`.

  NOTE: This module doesn't return a list of entries, but a `Ecto.Query.t`.


  This module `uses` `Rummage.Ecto.Hook`.

  Usage:
  For a regular search:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  searched by ascending `field_1`

  ```elixir
  alias Rummage.Ecto.Hooks.Search

  searched_queryable = Search.run(Parent, %{field_1: %{assoc: [], search_type: "like", search_term: "field_!"}}})

  ```

  For a case-insensitive search:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  searched by ascending case insensitive `field_1`.

  Keep in mind that `case_insensitive` can only be called for `text` fields

  ```elixir
  alias Rummage.Ecto.Hooks.Search

  searched_queryable = Search.run(Parent, %{field_1: %{assoc: [], search_type: "ilike", search_term: "field_!"}}})

  ```

  There are many other `search_types`. Check out `Rummage.Ecto.Services.BuildSearchQuery`'s docs
  to explore more `search_types`

  This module can be overridden with a custom module while using `Rummage.Ecto`
  in `Ecto` struct module:

  In the `Ecto` module:
  ```elixir
  Rummage.Ecto.rummage(queryable, rummage, search: CustomHook)
  ```

  OR

  Globally for all models in `config.exs`:
  ```elixir
  config :rummage_ecto,
    Rummage.Ecto,
   .search: CustomHook
  ```

  The `CustomHook` must use `Rummage.Ecto.Hook`. For examples of `CustomHook`,
  check out some `custom_hooks` that are shipped with `Rummage.Ecto`:
  `Rummage.Ecto.CustomHooks.SimpleSearch`, `Rummage.Ecto.CustomHooks.SimpleSort`,
    Rummage.Ecto.CustomHooks.SimplePaginate
  """

  use Rummage.Ecto.Hook

  import Ecto.Query

  @expected_keys ~w(search_type assoc search_term)a
  @err_msg "Error in params, No values given for keys: "

  alias Rummage.Ecto.Services.BuildSearchQuery

  @doc ~S"""
  This is the callback implementation of `Rummage.Ecto.Hook.run/2`.

  Builds a search `Ecto.Query.t` on top of a given `Ecto.Query.t` variable
  with given `params`.

  Besides an `Ecto.Query.t` an `Ecto.Schema` module can also be passed as it
  implements `Ecto.Queryable`

  Params is a `Map`, keys of which are field names which will be searched for and
  value corresponding to that key is a list of params for that key, which
  should include the keys: `#{Enum.join(@expected_keys, ", ")}`.

  This function expects a `search_type` and a list of `associations` (empty for none).
  The `search_term` is what the `field` will be matched to based on the
  `search_type`.

  For all `search_types`, refer to `Rummage.Ecto.Services.BuildSearchQuery`.

  If an expected key isn't given, a `Runtime Error` is raised.

  NOTE:This hook isn't responsible for doing type validations. That's the
  responsibility of the user sending `search_term` and `search_type`. Same
  goes for the validity of `assoc`.

  ## Examples
  When search_params are empty, it simply returns the same `queryable`:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> Search.run(Parent, %{})
      Parent

  When a non-empty map is passed as a field `params`, but with a missing key:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> Search.run(Parent, %{field: %{assoc: []}})
      ** (RuntimeError) Error in params, No values given for keys: search_type, search_term

  When a valid map of params is passed with an `Ecto.Schema` module:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> search_params = %{field1: %{assoc: [],
      ...> search_type: "like", search_term: "field1"}}
      iex> Search.run(Rummage.Ecto.Product, search_params)
      #Ecto.Query<from p in subquery(from p in Rummage.Ecto.Product), where: like(p.field1, ^"%field1%")>

  When a valid map of params is passed with an `Ecto.Query.t`:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> search_params = %{field1: %{assoc: [],
      ...> search_type: "like", search_term: "field1"}}
      iex> query = from p in "products"
      iex> Search.run(query, search_params)
      #Ecto.Query<from p in subquery(from p in "products"), where: like(p.field1, ^"%field1%")>

  When a valid map of params is passed with an `Ecto.Query.t`, with `assoc`s:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> search_params = %{field1: %{assoc: [inner: "category"],
      ...> search_type: "like", search_term: "field1"}}
      iex> query = from p in "products"
      iex> Search.run(query, search_params)
      #Ecto.Query<from p in subquery(from p in "products"), join: c in assoc(p, :category), where: like(c.field1, ^"%field1%")>

  When a valid map of params is passed with an `Ecto.Query.t`, with `assoc`s, with
  different join types:

      iex> alias Rummage.Ecto.Hooks.Search
      iex> import Ecto.Query
      iex> search_params = %{field1: %{assoc: [inner: "category", left: "category", cross: "category"],
      ...> search_type: "like", search_term: "field1"}}
      iex> query = from p in "products"
      iex> Search.run(query, search_params)
      #Ecto.Query<from p in subquery(from p in "products"), join: c0 in assoc(p, :category), left_join: c1 in assoc(c0, :category), cross_join: c2 in assoc(c1, :category), where: like(c2.field1, ^"%field1%")>

  """
  @spec run(Ecto.Query.t(), map()) :: Ecto.Query.t()
  def run(q, s), do: handle_search(q, s)

  # Helper function which handles addition of search query on top of
  # the sent queryable variable, for all search fields.
  defp handle_search(queryable, search_params) do
    search_params
    |> Map.to_list()
    |> Enum.reduce(queryable, &search_queryable(&1, &2))
  end

  # Helper function which handles addition of search query on top of
  # the sent queryable variable, for ONE search fields.
  # This delegates the query building to `BuildSearchQuery` module
  defp search_queryable(param, queryable) do
    field = elem(param, 0)
    field_params = elem(param, 1)

    :ok = validate_params(field_params)

    assocs = Map.get(field_params, :assoc)
    search_type = Map.get(field_params, :search_type)
    search_term = Map.get(field_params, :search_term)

    assocs
    |> Enum.reduce(from(e in subquery(queryable)), &join_by_assoc(&1, &2))
    |> BuildSearchQuery.run(field, search_type, search_term)
  end

  # Helper function which handles associations in a query with a join
  # type.
  defp join_by_assoc({join, assoc}, query) do
    join(query, join, [..., p1], p2 in assoc(p1, ^String.to_atom(assoc)))
  end

  # Helper function that validates the list of params based on
  # @expected_keys list
  defp validate_params(params) do
    key_validations = Enum.map(@expected_keys, &Map.fetch(params, &1))

    case Enum.filter(key_validations, & &1 == :error) do
      [] -> :ok
      _ -> raise @err_msg <> missing_keys(key_validations)
    end
  end

  # Helper function used to build error message using missing keys
  defp missing_keys(key_validations) do
    key_validations
    |> Enum.with_index()
    |> Enum.filter(fn {v, _i} -> v == :error end)
    |> Enum.map(fn {_v, i} -> Enum.at(@expected_keys, i) end)
    |> Enum.map(&to_string/1)
    |> Enum.join(", ")
  end

  @doc """
  Callback implementation for `Rummage.Ecto.Hook.format_params/2`.

  This just returns back `search_params` at this point.
  It doesn't matter what `queryable` or `opts` are.

  ## Examples
      iex> alias Rummage.Ecto.Hooks.Search
      iex> Search.format_params(Parent, %{}, %{})
      %{}
  """
  @spec format_params(Ecto.Query.t(), map(), keyword()) :: map()
  def format_params(_queryable, search_params, _opts), do: search_params
end

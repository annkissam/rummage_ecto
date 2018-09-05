defmodule Rummage.Ecto.Hook.Search do
  @moduledoc """
  `Rummage.Ecto.Hook.Search` is the default search hook that comes with
  `Rummage.Ecto`.

  This module provides a operations that can add searching functionality to
  a pipeline of `Ecto` queries. This module works by taking fields, and `search_type`,
  `search_term` and `assoc` associated with those `fields`.

  NOTE: This module doesn't return a list of entries, but a `Ecto.Query.t`.
  This module `uses` `Rummage.Ecto.Hook`.

  _____________________________________________________________________________

  # ABOUT:

  ## Arguments:

  This Hook expects a `queryable` (an `Ecto.Queryable`) and
  `search_params` (a `Map`). The map should be in the format:
  `%{field_name: %{assoc: [], search_term: true, search_type: :eq}}`

  Details:

  * `field_name`: The field name to search by.
  * `assoc`: List of associations in the search.
  * `search_term`: Term to compare the `field_name` against.
  * `search_type`: Determines the kind of search to perform. If `:eq`, it
                  expects the `field_name`'s value to be equal to `search_term`,
                  If `lt`, it expects it to be less than `search_term`.
                  To see all the `search_type`s, check
                  `Rummage.Ecto.Services.BuildSearchQuery`
  * `search_expr`: This is optional. Defaults to `:where`. This is the way current
                   search expression is appended to the existing query.
                   To see all the `search_expr`s, check
                   `Rummage.Ecto.Services.BuildSearchQuery`


  For example, if we want to search products with `available` = `true`, we would
  do the following:

  ```elixir
  Rummage.Ecto.Hook.Search.run(Product, %{available: %{assoc: [],
    search_type: :eq,
    search_term: true}})
  ```

  This can be used for a search with multiple fields as well. Say, we want to
  search for products that are `available`, but have a price less than `10.0`.

  ```elixir
  Rummage.Ecto.Hook.Search.run(Product,
    %{available: %{assoc: [],
      search_type: :eq,
      search_term: true},
    %{price: %{assoc: [],
      search_type: :lt,
      search_term: 10.0}})
  ```

  ## Assoications:

  Assocaitions can be given to this module's run function as a key corresponding
  to params associated with a field. For example, if we want to search products
  that belong to a category with category_name, "super", we would do the
  following:

  ```elixir
  category_name_params = %{assoc: [inner: :category], search_term: "super",
    search_type: :eq, search_expr: :where}

  Rummage.Ecto.Hook.Search.run(Product, %{category_name: category_name_params})
  ```

  The above operation will return an `Ecto.Query.t` struct which represents
  a query equivalent to:

  ```elixir
  from p in Product
  |> join(:inner, :category)
  |> where([p, c], c.category_name == ^"super")
  ```

  ____________________________________________________________________________

  # ASSUMPTIONS/NOTES:

  * This Hook has the default `search_type` of `:ilike`, which is
  case-insensitive.
  * This Hook has the default `search_expr` of `:where`.
  * This Hook assumes that the field passed is a field on the `Ecto.Schema`
  that corresponds to the last association in the `assoc` list or the `Ecto.Schema`
  that corresponds to the `from` in `queryable`, if `assoc` is an empty list.

  NOTE: It is adviced to not use multiple associated searches in one operation
  as `assoc` still has some minor bugs when used with multiple searches. If you
  need to use two searches with associations, I would pipe the call to another
  search operation:

  ```elixir
  Search.run(queryable, %{field1: %{assoc: [inner: :some_assoc]}}
  |> Search.run(%{field2: %{assoc: [inner: :some_assoc2]}}
  ```

  ____________________________________________________________________________

  # USAGE:

  For a regular search:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  searched by ascending `field_1`

  ```elixir
  alias Rummage.Ecto.Hook.Search

  searched_queryable = Search.run(Parent, %{field_1: %{assoc: [],
    search_type: :like, search_term: "field_!"}}})

  ```

  For a case-insensitive search:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  searched by ascending case insensitive `field_1`.

  Keep in mind that `case_insensitive` can only be called for `text` fields

  ```elixir
  alias Rummage.Ecto.Hook.Search

  searched_queryable = Search.run(Parent, %{field_1: %{assoc: [],
    search_type: :ilike, search_term: "field_!"}}})

  ```

  There are many other `search_types`. Check out
  `Rummage.Ecto.Services.BuildSearchQuery` docs to explore more `search_types`

  This module can be overridden with a custom module while using `Rummage.Ecto`
  in `Ecto` struct module:

  In the `Ecto` module:
  ```elixir
  Rummage.Ecto.rummage(queryable, rummage, search: CustomHook)
  ```

  OR

  Globally for all models in `config.exs`:
  ```elixir
  config :my_app,
    Rummage.Ecto,
   .search: CustomHook
  ```

  The `CustomHook` must use `Rummage.Ecto.Hook`. For examples of `CustomHook`,
  check out some `custom_hooks` that are shipped with `Rummage.Ecto`:
  `Rummage.Ecto.CustomHook.SimpleSearch`, `Rummage.Ecto.CustomHook.SimpleSort`,
    Rummage.Ecto.CustomHook.SimplePaginate
  """

  use Rummage.Ecto.Hook

  import Ecto.Query

  @expected_keys ~w{search_type assoc search_term}a
  @err_msg ~s{Error in params, No values given for keys: }

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

  This function expects a `search_expr`, `search_type` and a list of
  `associations` (empty for none).  The `search_term` is what the `field`
  will be matched to based on the `search_type` and `search_expr`.

  If no `search_expr` is given, it defaults to `where`.

  For all `search_exprs`, refer to `Rummage.Ecto.Services.BuildSearchQuery`.

  For all `search_types`, refer to `Rummage.Ecto.Services.BuildSearchQuery`.

  If an expected key isn't given, a `Runtime Error` is raised.

  NOTE:This hook isn't responsible for doing type validations. That's the
  responsibility of the user sending `search_term` and `search_type`. Same
  goes for the validity of `assoc`.

  ## Examples
  When search_params are empty, it simply returns the same `queryable`:

      iex> alias Rummage.Ecto.Hook.Search
      iex> import Ecto.Query
      iex> Search.run(Parent, %{})
      Parent

  When a non-empty map is passed as a field `params`, but with a missing key:

      iex> alias Rummage.Ecto.Hook.Search
      iex> import Ecto.Query
      iex> Search.run(Parent, %{field: %{assoc: []}})
      ** (RuntimeError) Error in params, No values given for keys: search_type, search_term

  When a valid map of params is passed with an `Ecto.Schema` module:

      iex> alias Rummage.Ecto.Hook.Search
      iex> import Ecto.Query
      iex> search_params = %{field1: %{assoc: [],
      ...> search_type: :like, search_term: "field1", search_expr: :where}}
      iex> Search.run(Rummage.Ecto.Product, search_params)
      #Ecto.Query<from p in subquery(from p in Rummage.Ecto.Product), where: like(p.field1, ^"%field1%")>

  When a valid map of params is passed with an `Ecto.Query.t`:

      iex> alias Rummage.Ecto.Hook.Search
      iex> import Ecto.Query
      iex> search_params = %{field1: %{assoc: [],
      ...> search_type: :like, search_term: "field1", search_expr: :where}}
      iex> query = from p in "products"
      iex> Search.run(query, search_params)
      #Ecto.Query<from p in subquery(from p in "products"), where: like(p.field1, ^"%field1%")>

  When a valid map of params is passed with an `Ecto.Query.t`, with `assoc`s:

      iex> alias Rummage.Ecto.Hook.Search
      iex> import Ecto.Query
      iex> search_params = %{field1: %{assoc: [inner: :category],
      ...> search_type: :like, search_term: "field1", search_expr: :or_where}}
      iex> query = from p in "products"
      iex> Search.run(query, search_params)
      #Ecto.Query<from p in subquery(from p in "products"), join: c in assoc(p, :category), or_where: like(c.field1, ^"%field1%")>

  When a valid map of params is passed with an `Ecto.Query.t`, with `assoc`s, with
  different join types:

      iex> alias Rummage.Ecto.Hook.Search
      iex> import Ecto.Query
      iex> search_params = %{field1: %{assoc: [inner: :category, left: :category, cross: :category],
      ...> search_type: :like, search_term: "field1", search_expr: :where}}
      iex> query = from p in "products"
      iex> Search.run(query, search_params)
      #Ecto.Query<from p in subquery(from p in "products"), join: c0 in assoc(p, :category), left_join: c1 in assoc(c0, :category), cross_join: c2 in assoc(c1, :category), where: like(c2.field1, ^"%field1%")>

  When a valid map of params is passed with an `Ecto.Query.t`, searching on
  a boolean param

      iex> alias Rummage.Ecto.Hook.Search
      iex> import Ecto.Query
      iex> search_params = %{available: %{assoc: [],
      ...> search_type: :eq, search_term: true, search_expr: :where}}
      iex> query = from p in "products"
      iex> Search.run(query, search_params)
      #Ecto.Query<from p in subquery(from p in "products"), where: p.available == ^true>

  When a valid map of params is passed with an `Ecto.Query.t`, searching on
  a float param

      iex> alias Rummage.Ecto.Hook.Search
      iex> import Ecto.Query
      iex> search_params = %{price: %{assoc: [],
      ...> search_type: :gteq, search_term: 10.0, search_expr: :where}}
      iex> query = from p in "products"
      iex> Search.run(query, search_params)
      #Ecto.Query<from p in subquery(from p in "products"), where: p.price >= ^10.0>

  When a valid map of params is passed with an `Ecto.Query.t`, searching on
  a boolean param, but with a wrong `search_type`.
  NOTE: This doesn't validate the search_type of search_term

      iex> alias Rummage.Ecto.Hook.Search
      iex> import Ecto.Query
      iex> search_params = %{available: %{assoc: [],
      ...> search_type: :ilike, search_term: true, search_expr: :where}}
      iex> query = from p in "products"
      iex> Search.run(query, search_params)
      ** (ArgumentError) argument error

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
    search_expr = Map.get(field_params, :search_expr, :where)
    field = resolve_field(field, queryable)

    assocs
    |> Enum.reduce(from(e in subquery(queryable)), &join_by_assoc(&1, &2))
    |> BuildSearchQuery.run(field, {search_expr, search_type}, search_term)
  end

  # Helper function which handles associations in a query with a join
  # type.
  defp join_by_assoc({join, assoc}, query) do
    join(query, join, [..., p1], p2 in assoc(p1, ^assoc))
  end

  # NOTE: These functions can be used in future for multiple search fields that
  # are associated.
  # defp applied_associations(queryable) when is_atom(queryable), do: []
  # defp applied_associations(queryable), do: Enum.map(queryable.joins, & Atom.to_string(elem(&1.assoc, 1)))

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

  This function ensures that params for each field have keys `assoc`, `search_type` and
  `search_expr` which are essential for running this hook module.

  ## Examples
      iex> alias Rummage.Ecto.Hook.Search
      iex> Search.format_params(Parent, %{field: %{}}, [])
      %{field: %{assoc: [], search_expr: :where, search_type: :eq}}

      iex> alias Rummage.Ecto.Hook.Search
      iex> Search.format_params(Parent, %{field: 1}, [])
      ** (RuntimeError) No scope `field` of type search defined in the Elixir.Parent
  """
  @spec format_params(Ecto.Query.t(), map(), keyword()) :: map()
  def format_params(queryable, search_params, _opts) do
    search_params
    |> Map.to_list()
    |> Enum.map(&put_keys(&1, queryable))
    |> Enum.into(%{})
  end

  defp put_keys({field, %{} = field_params}, _queryable) do
    field_params = field_params
      |> Map.put_new(:assoc, [])
      |> Map.put_new(:search_type, :eq)
      |> Map.put_new(:search_expr, :where)

    {field, field_params}
  end
  defp put_keys({search_scope, field_value}, queryable) do
    module = get_module(queryable)
    name = :"__rummage_search_#{search_scope}"
    {field, search_params} = case function_exported?(module, name, 1) do
      true -> apply(module, name, [field_value])
      _ -> raise "No scope `#{search_scope}` of type search defined in the #{module}"
    end

    put_keys({field, search_params}, queryable)
  end
end

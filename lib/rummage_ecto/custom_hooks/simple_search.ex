defmodule Rummage.Ecto.CustomHook.SimpleSearch do
  @moduledoc """
  `Rummage.Ecto.CustomHook.SimpleSearch` is an example of a Custom Hook that
  comes with `Rummage.Ecto`.

  This module provides a operations that can add searching functionality to
  a pipeline of `Ecto` queries. This module works by taking fields, and
  `search_type` and `search_term`.

  This module doesn't support associations and hence is a simple alternative
  to Rummage's default search hook.

  NOTE: This module doesn't return a list of entries, but a `Ecto.Query.t`.
  This module `uses` `Rummage.Ecto.Hook`.

  _____________________________________________________________________________

  # ABOUT:

  ## Arguments:

  This Hook expects a `queryable` (an `Ecto.Queryable`) and
  `search_params` (a `Map`). The map should be in the format:
  `%{field_name: %{search_term: true, search_type: :eq}}`

  Details:

  * `field_name`: The field name to search by.
  * `search_term`: Term to compare the `field_name` against.
  * `search_type`: Determines the kind of search to perform. If `:eq`, it
                  expects the `field_name`'s value to be equal to `search_term`,
                  If `lt`, it expects it to be less than `search_term`.
                  To see all the `search_type`s, check
                  `Rummage.Ecto.Services.BuildSearchQuery`
  * `search_expr`: This is optional. Defaults to `:where`. This is the way the
                   search expression is appended to the existing query.
                   To see all the `search_expr`s, check
                   `Rummage.Ecto.Services.BuildSearchQuery`


  For example, if we want to search products with `available` = `true`, we would
  do the following:

  ```elixir
  Rummage.Ecto.CustomHook.SimpleSearch.run(Product, %{available:
    %{search_type: :eq,
    search_term: true}})
  ```

  This can be used for a search with multiple fields as well. Say, we want to
  search for products that are `available`, but have a price less than `10.0`.

  ```elixir
  Rummage.Ecto.CustomHook.SimpleSearch.run(Product,
    %{available: %{search_type: :eq,
      search_term: true},
    %{price: %{search_type: :lt,
      search_term: 10.0}})
  ```

  ## Assoications:

  This module doesn't support assocations.

  ____________________________________________________________________________

  # ASSUMPTIONS/NOTES:

  * This Hook assumes that the searched field is a part of the schema passed
  as the `queryable`.
  * This Hook has the default `search_type` of `:eq`.
  * This Hook has the default `search_expr` of `:where`.

  ____________________________________________________________________________

  # USAGE:

  For a regular search:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  searched by ascending `field_1`

  ```elixir
  alias Rummage.Ecto.CustomHook.SimpleSearch

  searched_queryable = SimpleSearch.run(Parent,
    %{field_1: %{search_type: :like, search_term: "field_!"}}})

  ```

  For a case-insensitive search:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  searched by ascending case insensitive `field_1`.

  Keep in mind that `case_insensitive` can only be called for `text` fields

  ```elixir
  alias Rummage.Ecto.CustomHook.SimpleSearch

  searched_queryable = SimpleSearch.run(Parent,
    %{field_1: %{ search_type: "ilike", search_term: "field_!"}}})

  ```

  There are many other `search_types`. Check out
  `Rummage.Ecto.Services.BuildSearchQuery` docs to explore more `search_types`.

  This module can be used by overriding the default module. This can be done
  in the following ways:

  In the `Rummage.Ecto` call:
  ```elixir
  Rummage.Ecto.rummage(queryable, rummage,
    search: Rummage.Ecto.CustomHook.SimpleSearch)

  or

  MySchema.rummage(rummage, search: Rummage.Ecto.CustomHook.SimpleSearch)
  ```

  OR

  Globally for all models in `config.exs`:
  ```elixir
  config :my_app,
    Rummage.Ecto,
    search: Rummage.Ecto.CustomHook.SimpleSearch
  ```

  OR

  When `using` Rummage.Ecto with an `Ecto.Schema`:
  ```elixir
  defmodule MySchema do
    use Rummage.Ecto, repo: SomeRepo,
      search: Rummage.Ecto.CustomHook.SimpleSearch
  end
  """

  use Rummage.Ecto.Hook

  import Ecto.Query

  @expected_keys ~w(search_type search_term)a
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

  This function expects a `search_expr`, `search_type`.
  The `search_term` is what the `field`
  will be matched to based on the `search_type` and `search_expr`.

  If no `search_expr` is given, it defaults to `where`.

  For all `search_exprs`, refer to `Rummage.Ecto.Services.BuildSearchQuery`.

  For all `search_types`, refer to `Rummage.Ecto.Services.BuildSearchQuery`.

  If an expected key isn't given, a `Runtime Error` is raised.

  NOTE:This hook isn't responsible for doing type validations. That's the
  responsibility of the user sending `search_term` and `search_type`.
  ## Examples
  When search_params are empty, it simply returns the same `queryable`:

      iex> alias Rummage.Ecto.CustomHook.SimpleSearch
      iex> import Ecto.Query
      iex> SimpleSearch.run(Parent, %{})
      Parent

  When a non-empty map is passed as a field `params`, but with a missing key:

      iex> alias Rummage.Ecto.CustomHook.SimpleSearch
      iex> import Ecto.Query
      iex> SimpleSearch.run(Parent, %{field: %{search_type: :eq}})
      ** (RuntimeError) Error in params, No values given for keys: search_term

  When a valid map of params is passed with an `Ecto.Schema` module:

      iex> alias Rummage.Ecto.CustomHook.SimpleSearch
      iex> import Ecto.Query
      iex> search_params = %{field1: %{
      ...> search_type: :like,
      ...> search_term: "field1",
      ...> search_expr: :where}}
      iex> SimpleSearch.run(Rummage.Ecto.Product, search_params)
      #Ecto.Query<from p in subquery(from p in Rummage.Ecto.Product), where: like(p.field1, ^"%field1%")>

  When a valid map of params is passed with an `Ecto.Query.t`:

      iex> alias Rummage.Ecto.CustomHook.SimpleSearch
      iex> import Ecto.Query
      iex> search_params = %{field1: %{
      ...> search_type: :like,
      ...> search_term: "field1",
      ...> search_expr: :where}}
      iex> query = from p in "products"
      iex> SimpleSearch.run(query, search_params)
      #Ecto.Query<from p in subquery(from p in "products"), where: like(p.field1, ^"%field1%")>

  When a valid map of params is passed with an `Ecto.Query.t` and `:on_where`:

      iex> alias Rummage.Ecto.CustomHook.SimpleSearch
      iex> import Ecto.Query
      iex> search_params = %{field1: %{
      ...> search_type: :like,
      ...> search_term: "field1",
      ...> search_expr: :or_where}}
      iex> query = from p in "products"
      iex> SimpleSearch.run(query, search_params)
      #Ecto.Query<from p in subquery(from p in "products"), or_where: like(p.field1, ^"%field1%")>

  When a valid map of params is passed with an `Ecto.Query.t`, searching on
  a boolean param

      iex> alias Rummage.Ecto.CustomHook.SimpleSearch
      iex> import Ecto.Query
      iex> search_params = %{available: %{
      ...> search_type: :eq,
      ...> search_term: true,
      ...> search_expr: :where}}
      iex> query = from p in "products"
      iex> SimpleSearch.run(query, search_params)
      #Ecto.Query<from p in subquery(from p in "products"), where: p.available == ^true>

  When a valid map of params is passed with an `Ecto.Query.t`, searching on
  a float param

      iex> alias Rummage.Ecto.CustomHook.SimpleSearch
      iex> import Ecto.Query
      iex> search_params = %{price: %{
      ...> search_type: :gteq,
      ...> search_term: 10.0,
      ...> search_expr: :where}}
      iex> query = from p in "products"
      iex> SimpleSearch.run(query, search_params)
      #Ecto.Query<from p in subquery(from p in "products"), where: p.price >= ^10.0>

  When a valid map of params is passed with an `Ecto.Query.t`, searching on
  a boolean param, but with a wrong `search_type`.
  NOTE: This doesn't validate the search_type of search_term

      iex> alias Rummage.Ecto.CustomHook.SimpleSearch
      iex> import Ecto.Query
      iex> search_params = %{available: %{
      ...> search_type: :ilike,
      ...> search_term: true,
      ...> search_expr: :where}}
      iex> query = from p in "products"
      iex> SimpleSearch.run(query, search_params)
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

    search_type = Map.get(field_params, :search_type)
    search_term = Map.get(field_params, :search_term)
    search_expr = Map.get(field_params, :search_expr, :where)

    BuildSearchQuery.run(from(e in subquery(queryable)),
      field, {search_expr, search_type}, search_term)
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

  This function ensures that params for each field have keys `assoc`, `search_type` and
  `search_expr` which are essential for running this hook module.

  ## Examples
      iex> alias Rummage.Ecto.CustomHook.SimpleSearch
      iex> SimpleSearch.format_params(Parent, %{field: %{}}, [])
      %{field: %{search_expr: :where, search_type: :eq}}
  """
  @spec format_params(Ecto.Query.t(), map(), keyword()) :: map()
  def format_params(_queryable, search_params, _opts) do
    search_params
    |> Map.to_list()
    |> Enum.map(&put_keys/1)
    |> Enum.into(%{})
  end

  defp put_keys({field, field_params}) do
    field_params = field_params
      |> Map.put_new(:search_type, :eq)
      |> Map.put_new(:search_expr, :where)

    {field, field_params}
  end
end

defmodule Rummage.Ecto.CustomHook.SimpleSort do
  @moduledoc """
  `Rummage.Ecto.CustomHook.SimpleSort` is the default sort hook that comes with
  `Rummage.Ecto`.

  This module provides a operations that can add sorting functionality to
  a pipeline of `Ecto` queries. This module works by taking the `field` that should
  be used to `order_by`, `order` which can be `asc` or `desc`.

  This module doesn't support associations and hence is a simple alternative
  to Rummage's default search hook.

  NOTE: This module doesn't return a list of entries, but a `Ecto.Query.t`.
  This module `uses` `Rummage.Ecto.Hook`.

  _____________________________________________________________________________

  # ABOUT:

  ## Arguments:

  This Hook expects a `queryable` (an `Ecto.Queryable`) and
  `sort_params` (a `Map`). The map should be in the format:
  `%{field: :field_name, order: :asc}`

  Details:

  * `field`: The field name (atom) to sorted by.
  * `order`: Specifies the type of order `asc` or `desc`.
  * `ci` : Case Insensitivity. Defaults to `false`


  For example, if we want to sort products with descending `price`, we would
  do the following:

  ```elixir
  Rummage.Ecto.CustomHook.SimpleSort.run(Product, %{field: :price,
    order: :desc})
  ```

  ## Assoications:

  This module doesn't support assocations.

  ____________________________________________________________________________

  # ASSUMPTIONS/NOTES:

  * This Hook has the default `order` of `:asc`.
  * This Hook assumes that the searched field is a part of the schema passed
  as the `queryable`.

  ____________________________________________________________________________

  # USAGE:

  For a regular sort:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  sorted by ascending `field_1`

  ```elixir
  alias Rummage.Ecto.CustomHook.SimpleSort

  sorted_queryable = SimpleSort.run(Parent, %{field: :name, order: :asc}})
  ```

  For a case-insensitive sort:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  sorted by ascending case insensitive `field_1`.

  Keep in mind that `case_insensitive` can only be called for `text` fields

  ```elixir
  alias Rummage.Ecto.CustomHook.SimpleSort

  sorted_queryable = SimpleSort.run(Parent, %{field: :name, order: :asc, ci: true}})
  ```


  This module can be overridden with a custom module while using `Rummage.Ecto`
  in `Ecto` struct module.

  In the `Ecto` module:
  ```elixir
  Rummage.Ecto.rummage(queryable, rummage, sort: CustomHook)
  ```

  OR

  Globally for all models in `config.exs`:
  ```elixir
  config :rummage_ecto,
    Rummage.Ecto,
   .sort: CustomHook
  ```

  The `CustomHook` must use `Rummage.Ecto.Hook`. For examples of `CustomHook`,
  check out some `custom_hooks` that are shipped with `Rummage.Ecto`:
  `Rummage.Ecto.CustomHook.SimpleSearch`, `Rummage.Ecto.CustomHook.SimpleSort`,
    Rummage.Ecto.CustomHook.SimplePaginate

  """

  use Rummage.Ecto.Hook

  import Ecto.Query

  @expected_keys ~w(field order)a
  @err_msg "Error in params, No values given for keys: "

  @doc """
  This is the callback implementation of `Rummage.Ecto.Hook.run/2`.

  Builds a sort `Ecto.Query.t` on top of the given `Ecto.Queryable` variable
  using given `params`.

  Besides an `Ecto.Query.t` an `Ecto.Schema` module can also be passed as it
  implements `Ecto.Queryable`

  Params is a `Map` which is expected to have the keys `#{Enum.join(@expected_keys, ", ")}`.

  This funciton expects a `field` atom, `order` which can be `asc` or `desc`,
  `ci` which is a boolean indicating the case-insensitivity.

  ## Examples
  When an empty map is passed as `params`:

      iex> alias Rummage.Ecto.CustomHook.SimpleSort
      iex> SimpleSort.run(Parent, %{})
      ** (RuntimeError) Error in params, No values given for keys: field, order

  When a non-empty map is passed as `params`, but with a missing key:

      iex> alias Rummage.Ecto.CustomHook.SimpleSort
      iex> SimpleSort.run(Parent, %{field: :name})
      ** (RuntimeError) Error in params, No values given for keys: order

  When a valid map of params is passed with an `Ecto.Schema` module:

      iex> alias Rummage.Ecto.CustomHook.SimpleSort
      iex> SimpleSort.run(Rummage.Ecto.Product, %{field: :name, order: :asc})
      #Ecto.Query<from p in subquery(from p in Rummage.Ecto.Product), order_by: [asc: p.name]>

  When the `queryable` passed is an `Ecto.Query` variable:

      iex> alias Rummage.Ecto.CustomHook.SimpleSort
      iex> import Ecto.Query
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> SimpleSort.run(queryable, %{field: :name, order: :asc})
      #Ecto.Query<from p in subquery(from p in "products"), order_by: [asc: p.name]>


  When the `queryable` passed is an `Ecto.Query` variable, with `desc` order:

      iex> alias Rummage.Ecto.CustomHook.SimpleSort
      iex> import Ecto.Query
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> SimpleSort.run(queryable, %{field: :name, order: :desc})
      #Ecto.Query<from p in subquery(from p in "products"), order_by: [desc: p.name]>

  When the `queryable` passed is an `Ecto.Query` variable, with `ci` true:

      iex> alias Rummage.Ecto.CustomHook.SimpleSort
      iex> import Ecto.Query
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> SimpleSort.run(queryable, %{field: :name, order: :asc, ci: true})
      #Ecto.Query<from p in subquery(from p in "products"), order_by: [asc: fragment("lower(?)", p.name)]>

  """
  @spec run(Ecto.Query.t(), map()) :: Ecto.Query.t()
  def run(queryable, sort_params) do
    :ok = validate_params(sort_params)

    handle_sort(queryable, sort_params)
  end

  # Helper function which handles addition of paginated query on top of
  # the sent queryable variable
  defp handle_sort(queryable, sort_params) do
    order = Map.get(sort_params, :order)
    field = Map.get(sort_params, :field)
    ci = Map.get(sort_params, :ci, false)

    handle_ordering(from(e in subquery(queryable)), field, order, ci)
  end

  # This is a helper macro to get case_insensitive query using fragments
  defmacrop case_insensitive(field) do
    quote do
      fragment("lower(?)", unquote(field))
    end
  end

  # Helper function that handles adding order_by to a query based on order type
  # case insensitivity and field
  defp handle_ordering(queryable, field, order, ci) do
    order_by_assoc(queryable, order, field, ci)
  end

  defp order_by_assoc(queryable, order_type, field, false) do
    order_by(queryable, [p0, ..., p2], [{^order_type, field(p2, ^field)}])
  end

  defp order_by_assoc(queryable, order_type, field, true) do
    order_by(queryable, [p0, ..., p2],
             [{^order_type, case_insensitive(field(p2, ^field))}])
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

  This function ensures that params for each field have keys `assoc`, `order1
  which are essential for running this hook module.

  ## Examples
      iex> alias Rummage.Ecto.CustomHook.SimpleSort
      iex> SimpleSort.format_params(Parent, %{}, [])
      %{order: :asc}
  """
  @spec format_params(Ecto.Query.t(), map(), keyword()) :: map()
  def format_params(_queryable, sort_params, _opts) do
    sort_params
    |> Map.put_new(:order, :asc)
  end
end

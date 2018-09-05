defmodule Rummage.Ecto.Hook.Sort do
  @moduledoc """
  `Rummage.Ecto.Hook.Sort` is the default sort hook that comes with
  `Rummage.Ecto`.

  This module provides a operations that can add sorting functionality to
  a pipeline of `Ecto` queries. This module works by taking the `field` that should
  be used to `order_by`, `order` which can be `asc` or `desc` and `assoc`,
  which is a keyword list of assocations associated with those `fields`.

  NOTE: This module doesn't return a list of entries, but a `Ecto.Query.t`.
  This module `uses` `Rummage.Ecto.Hook`.

  _____________________________________________________________________________

  # ABOUT:

  ## Arguments:

  This Hook expects a `queryable` (an `Ecto.Queryable`) and
  `sort_params` (a `Map`). The map should be in the format:
  `%{field: :field_name, assoc: [], order: :asc}`

  Details:

  * `field`: The field name (atom) to sorted by.
  * `assoc`: List of associations in the sort.
  * `order`: Specifies the type of order `asc` or `desc`.
  * `ci` : Case Insensitivity. Defaults to `false`


  For example, if we want to sort products with descending `price`, we would
  do the following:

  ```elixir
  Rummage.Ecto.Hook.Sort.run(Product, %{field: :price,
    assoc: [], order: :desc})
  ```

  ## Assoications:

  Assocaitions can be given to this module's run function as a key corresponding
  to params associated with a field. For example, if we want to sort products
  that belong to a category by ascending category_name, we would do the
  following:

  ```elixir
  params = %{field: :category_name, assoc: [inner: :category],
    order: :asc}

  Rummage.Ecto.Hook.Sort.run(Product, params)
  ```

  The above operation will return an `Ecto.Query.t` struct which represents
  a query equivalent to:

  ```elixir
  from p in Product
  |> join(:inner, :category)
  |> order_by([p, c], {asc, c.category_name})
  ```

  ____________________________________________________________________________

  # ASSUMPTIONS/NOTES:

  * This Hook has the default `order` of `:asc`.
  * This Hook has the default `assoc` of `[]`.
  * This Hook assumes that the field passed is a field on the `Ecto.Schema`
  that corresponds to the last association in the `assoc` list or the `Ecto.Schema`
  that corresponds to the `from` in `queryable`, if `assoc` is an empty list.

  NOTE: It is adviced to not use multiple associated sorts in one operation
  as `assoc` still has some minor bugs when used with multiple sorts. If you
  need to use two sorts with associations, I would pipe the call to another
  sort operation:

  ```elixir
  Sort.run(queryable, params1}
  |> Sort.run(%{field2: params2}
  ```

  ____________________________________________________________________________

  # USAGE:

  For a regular sort:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  sorted by ascending `field_1`

  ```elixir
  alias Rummage.Ecto.Hook.Sort

  sorted_queryable = Sort.run(Parent, %{assoc: [], field: :name, order: :asc}})
  ```

  For a case-insensitive sort:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  sorted by ascending case insensitive `field_1`.

  Keep in mind that `case_insensitive` can only be called for `text` fields

  ```elixir
  alias Rummage.Ecto.Hook.Sort

  sorted_queryable = Sort.run(Parent, %{assoc: [], field: :name, order: :asc, ci: true}})
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

  @expected_keys ~w{field order assoc}a
  @err_msg ~s{Error in params, No values given for keys: }

  # Only for Postgres (only one interpolation is supported)
  # TODO: Fix this once Ecto 3.0 comes out with `unsafe_fragment`
  @supported_fragments_one ["date_part('day', ?)",
                            "date_part('month', ?)",
                            "date_part('year', ?)",
                            "date_part('hour', ?)",
                            "lower(?)",
                            "upper(?)"]

  @supported_fragments_two ["concat(?, ?)",
                            "coalesce(?, ?)"]


  @doc """
  This is the callback implementation of `Rummage.Ecto.Hook.run/2`.

  Builds a sort `Ecto.Query.t` on top of the given `Ecto.Queryable` variable
  using given `params`.

  Besides an `Ecto.Query.t` an `Ecto.Schema` module can also be passed as it
  implements `Ecto.Queryable`

  Params is a `Map` which is expected to have the keys `#{Enum.join(@expected_keys, ", ")}`.

  This funciton expects a `field` atom, `order` which can be `asc` or `desc`,
  `ci` which is a boolean indicating the case-insensitivity and `assoc` which
  is a list of associations with their join types.

  ## Examples
  When an empty map is passed as `params`:

      iex> alias Rummage.Ecto.Hook.Sort
      iex> Sort.run(Parent, %{})
      ** (RuntimeError) Error in params, No values given for keys: field, order, assoc

  When a non-empty map is passed as `params`, but with a missing key:

      iex> alias Rummage.Ecto.Hook.Sort
      iex> Sort.run(Parent, %{field: :name})
      ** (RuntimeError) Error in params, No values given for keys: order, assoc

  When a valid map of params is passed with an `Ecto.Schema` module:

      iex> alias Rummage.Ecto.Hook.Sort
      iex> Sort.run(Rummage.Ecto.Product, %{field: :name, assoc: [], order: :asc})
      #Ecto.Query<from p in subquery(from p in Rummage.Ecto.Product), order_by: [asc: p.name]>

  When the `queryable` passed is an `Ecto.Query` variable:

      iex> alias Rummage.Ecto.Hook.Sort
      iex> import Ecto.Query
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> Sort.run(queryable, %{field: :name, assoc: [], order: :asc})
      #Ecto.Query<from p in subquery(from p in "products"), order_by: [asc: p.name]>


  When the `queryable` passed is an `Ecto.Query` variable, with `desc` order:

      iex> alias Rummage.Ecto.Hook.Sort
      iex> import Ecto.Query
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> Sort.run(queryable, %{field: :name, assoc: [], order: :desc})
      #Ecto.Query<from p in subquery(from p in "products"), order_by: [desc: p.name]>

  When the `queryable` passed is an `Ecto.Query` variable, with `ci` true:

      iex> alias Rummage.Ecto.Hook.Sort
      iex> import Ecto.Query
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> Sort.run(queryable, %{field: :name, assoc: [], order: :asc, ci: true})
      #Ecto.Query<from p in subquery(from p in "products"), order_by: [asc: fragment("lower(?)", p.name)]>

  When the `queryable` passed is an `Ecto.Query` variable, with associations:

      iex> alias Rummage.Ecto.Hook.Sort
      iex> import Ecto.Query
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> Sort.run(queryable, %{field: :name, assoc: [inner: :category, left: :category], order: :asc})
      #Ecto.Query<from p in subquery(from p in "products"), join: c0 in assoc(p, :category), left_join: c1 in assoc(c0, :category), order_by: [asc: c1.name]>

  When the `queryable` passed is an `Ecto.Schema` module with associations,
  `desc` order and `ci` true:

      iex> alias Rummage.Ecto.Hook.Sort
      iex> queryable = Rummage.Ecto.Product
      Rummage.Ecto.Product
      iex> Sort.run(queryable, %{field: :name, assoc: [inner: :category], order: :desc, ci: true})
      #Ecto.Query<from p in subquery(from p in Rummage.Ecto.Product), join: c in assoc(p, :category), order_by: [desc: fragment("lower(?)", c.name)]>
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
    field = sort_params
      |> Map.get(:field)
      |> resolve_field(queryable)

    assocs = Map.get(sort_params, :assoc)
    ci = Map.get(sort_params, :ci, false)

    assocs
    |> Enum.reduce(from(e in subquery(queryable)), &join_by_assoc(&1, &2))
    |> handle_ordering(field, order, ci)
  end

  # Helper function which handles associations in a query with a join
  # type.
  defp join_by_assoc({join, assoc}, query) do
    join(query, join, [..., p1], p2 in assoc(p1, ^assoc))
  end

  # This is a helper macro to get case_insensitive query using fragments
  defmacrop case_insensitive(field) do
    quote do
      fragment("lower(?)", unquote(field))
    end
  end

  # NOTE: These functions can be used in future for multiple sort fields that
  # are associated.
  # defp applied_associations(queryable) when is_atom(queryable), do: []
  # defp applied_associations(queryable), do: Enum.map(queryable.joins, & Atom.to_string(elem(&1.assoc, 1)))

  # Helper function that handles adding order_by to a query based on order type
  # case insensitivity and field
  defp handle_ordering(queryable, field, order, ci) do
    order_by_assoc(queryable, order, field, ci)
  end

  for fragment <- @supported_fragments_one do
    defp order_by_assoc(queryable, order_type, {:fragment, unquote(fragment), field}, false) do
      order_by(queryable, [p0, ..., p2], [{^order_type, fragment(unquote(fragment), field(p2, ^field))}])
    end

    defp order_by_assoc(queryable, order_type, {:fragment, unquote(fragment), field}, true) do
      order_by(queryable, [p0, ..., p2],
               [{^order_type, case_insensitive(fragment(unquote(fragment), field(p2, ^field)))}])
    end
  end

  for fragment <- @supported_fragments_two do
    defp order_by_assoc(queryable, order_type, {:fragment, unquote(fragment), field1, field2}, false) do
      order_by(queryable, [p0, ..., p2], [{^order_type, fragment(unquote(fragment), field(p2, ^field1), field(p2, ^field2))}])
    end

    defp order_by_assoc(queryable, order_type, {:fragment, unquote(fragment), field1, field2}, true) do
      order_by(queryable, [p0, ..., p2],
               [{^order_type, case_insensitive(fragment(unquote(fragment), field(p2, ^field1), field(p2, ^field2)))}])
    end
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
      iex> alias Rummage.Ecto.Hook.Sort
      iex> Sort.format_params(Parent, %{}, [])
      %{assoc: [], order: :asc}
  """
  @spec format_params(Ecto.Query.t(), map() | tuple(), keyword()) :: map()
  def format_params(queryable, {sort_scope, order}, opts) do
    module = get_module(queryable)
    name = :"__rummage_sort_#{sort_scope}"
    sort_params = case function_exported?(module, name, 1) do
      true -> apply(module, name, [order])
      _ -> raise "No scope `#{sort_scope}` of type sort defined in the #{module}"
    end

    format_params(queryable, sort_params, opts)
  end
  def format_params(_queryable, sort_params, _opts) do
    sort_params
    |> Map.put_new(:assoc, [])
    |> Map.put_new(:order, :asc)
  end
end

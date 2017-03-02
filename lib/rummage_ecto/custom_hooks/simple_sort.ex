defmodule Rummage.Ecto.CustomHooks.SimpleSort do
  @moduledoc """
  `Rummage.Ecto.CustomHooks.SimpleSort` is a custom sort hook that comes shipped
  with `Rummage.Ecto`.

  Usage:
  For a regular sort:

  ```elixir
  alias Rummage.Ecto.CustomHooks.SimpleSort

  # This returns a queryable which upon running will give a list of `Parent`(s)
  # sorted by ascending field_1
  sorted_queryable = SimpleSort.run(Parent, %{"sort" => "field_1.asc"})
  ```

  For a case-insensitive sort:

  ```elixir
  alias Rummage.Ecto.CustomHooks.SimpleSort

  # This returns a queryable which upon running will give a list of `Parent`(s)
  # sorted by ascending case insensitive field_1
  # Keep in mind that case insensitive can only be called for text fields
  sorted_queryable = SimpleSort.run(Parent, %{"sort" => "field_1.asc.ci"})
  ```

  This module can be used by overriding the default search module. This can be done
  in the following ways:

  In the `Ecto` module:
  ```elixir
  defmodule SomeModule do
    use Ecto.Schema
    use Rummage.Ecto, sort_hook: Rummage.Ecto.CustomHooks.SimpleSort
  end
  ```

  OR

  Globally for all models in `config.exs` (NOT Recommended):
  ```elixir
  config :rummage_ecto,
    Rummage.Ecto,
    default_search: Rummage.Ecto.CustomHooks.SimpleSort
  ```
  """

  import Ecto.Query

  @behaviour Rummage.Ecto.Hook

  @doc """
  Builds a sort `queryable` on top of the given `queryable` from the rummage parameters
  from the given `rummage` struct.

  ## Examples
  When rummage `struct` passed doesn't have the key `"sort"`, it simply returns the
  `queryable` itself:

      iex> alias Rummage.Ecto.CustomHooks.SimpleSort
      iex> import Ecto.Query
      iex> SimpleSort.run(Parent, %{})
      Parent

  When the `queryable` passed is not just a `struct`:

      iex> alias Rummage.Ecto.CustomHooks.SimpleSort
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex>  SimpleSort.run(queryable, %{})
      #Ecto.Query<from p in "parents">

  When rummage `struct` passed has the key `"sort"`, but with a value of `{}`, `""`
  or `[]` it simply returns the `queryable` itself:

      iex> alias Rummage.Ecto.CustomHooks.SimpleSort
      iex> import Ecto.Query
      iex> SimpleSort.run(Parent, %{"sort" => {}})
      Parent

      iex> alias Rummage.Ecto.CustomHooks.SimpleSort
      iex> import Ecto.Query
      iex> SimpleSort.run(Parent, %{"sort" => ""})
      Parent

      iex> alias Rummage.Ecto.CustomHooks.SimpleSort
      iex> import Ecto.Query
      iex> SimpleSort.run(Parent, %{"sort" => []})
      Parent

  When rummage `struct` passed has the key `"sort"`, with `field` and `order`
  it returns a sorted version of the `queryable` passed in as the argument:

      iex> alias Rummage.Ecto.CustomHooks.SimpleSort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => "field_1.asc"}
      %{"sort" => "field_1.asc"}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> SimpleSort.run(queryable, rummage)
      #Ecto.Query<from p in "parents", order_by: [asc: p.field_1]>


      iex> alias Rummage.Ecto.CustomHooks.SimpleSort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => "field_1.desc"}
      %{"sort" => "field_1.desc"}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> SimpleSort.run(queryable, rummage)
      #Ecto.Query<from p in "parents", order_by: [desc: p.field_1]>


  When no `order` is specified, it returns the `queryable` itself:

      iex> alias Rummage.Ecto.CustomHooks.SimpleSort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => "field_1"}
      %{"sort" => "field_1"}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> SimpleSort.run(queryable, rummage)
      #Ecto.Query<from p in "parents", order_by: []>

  When rummage `struct` passed has `case-insensitive` sort, it returns
  a sorted version of the `queryable` with `case_insensitive` arguments:

      iex> alias Rummage.Ecto.CustomHooks.SimpleSort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => "field_1.asc.ci"}
      %{"sort" => "field_1.asc.ci"}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> SimpleSort.run(queryable, rummage)
      #Ecto.Query<from p in "parents", order_by: [asc: fragment("lower(?)", ^:field_1)]>

      iex> alias Rummage.Ecto.CustomHooks.SimpleSort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => "field_1.desc.ci"}
      %{"sort" => "field_1.desc.ci"}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> SimpleSort.run(queryable, rummage)
      #Ecto.Query<from p in "parents", order_by: [desc: fragment("lower(?)", ^:field_1)]>
  """
  @spec run(Ecto.Query.t, map) :: {Ecto.Query.t, map}
  def run(queryable, rummage) do
    sort_params = Map.get(rummage, "sort")

    case sort_params do
      a when a in [nil, [], {}, ""] -> queryable
      _ ->
        case Regex.match?(~r/\w.ci+$/, sort_params) do
          true ->
            sort_params = sort_params
              |> String.split(".")
              |> Enum.drop(-1)
              |> Enum.join(".")

            handle_ci_sort(queryable, sort_params)
          _ -> handle_sort(queryable, sort_params)
        end
    end
  end

  defmacrop case_insensitive(field) do
    quote do
      fragment("lower(?)", unquote(field))
    end
  end

  defp handle_sort(queryable, sort_params), do: queryable |> order_by(^consolidate_order_params(sort_params))

  defp handle_ci_sort(queryable, sort_params) do
    order_param = sort_params
      |> consolidate_order_params
      |> Enum.at(0)

    queryable
    |> order_by([{^elem(order_param, 0),
      case_insensitive(^elem(order_param, 1))}])
  end

  defp consolidate_order_params(sort_params) do
    case Regex.match?(~r/\w.asc+$/, sort_params)
      or Regex.match?(~r/\w.desc+$/, sort_params)
      do
      true -> add_order_params([], sort_params)
      _ -> []
    end
  end

  defp add_order_params(order_params, unparsed_field) do
    parsed_field = unparsed_field
      |> String.split(".")
      |> Enum.drop(-1)
      |> Enum.join(".")
      |> String.to_atom

    order_type = unparsed_field
      |> String.split(".")
      |> Enum.at(-1)
      |> String.to_atom

    Keyword.put(order_params, order_type, parsed_field)
  end
end

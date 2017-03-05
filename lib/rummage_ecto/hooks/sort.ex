defmodule Rummage.Ecto.Hooks.Sort do
  @moduledoc """
  `Rummage.Ecto.Hooks.Sort` is the default sort hook that comes shipped
  with `Rummage.Ecto`.

  Usage:
  For a regular sort:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  sorted by ascending `field_1`

  ```elixir
  alias Rummage.Ecto.Hooks.Sort

  sorted_queryable = Sort.run(Parent, %{"sort" => %{"assoc" => [], "field" => "field_1.asc"}])
  ```

  For a case-insensitive sort:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  sorted by ascending case insensitive `field_1`.

  Keep in mind that `case_insensitive` can only be called for `text` fields

  ```elixir
  alias Rummage.Ecto.Hooks.Sort

  sorted_queryable = Sort.run(Parent, %{"sort" => %{"assoc" => [], "field" => "field_1.asc.ci"}])
  ```


  This module can be overridden with a custom module while using `Rummage.Ecto`
  in `Ecto` struct module.

  In the `Ecto` module:
  ```elixir
  defmodule SomeModule do
    use Ecto.Schema
    use Rummage.Ecto, sort_hook: CustomHook
  end
  ```

  OR

  Globally for all models in `config.exs` (NOT Recommended):
  ```elixir
  config :rummage_ecto,
    Rummage.Ecto,
    default_sort: CustomHook
  ```

  The `CustomHook` must implement `@behaviour Rummage.Ecto.Hook`. For examples of `CustomHook`, check out some
    `custom_hooks` that are shipped with elixir:

      * `Rummage.Ecto.CustomHooks.SimpleSearch`
      * `Rummage.Ecto.CustomHooks.SimpleSort`
  """

  import Ecto.Query

  @behaviour Rummage.Ecto.Hook

  @doc """
  Builds a sort `queryable` on top of the given `queryable` from the rummage parameters
  from the given `rummage` struct.

  ## Examples
  When rummage `struct` passed doesn't have the key `"sort"`, it simply returns the
  `queryable` itself:

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> Sort.run(Parent, %{})
      Parent

  When the `queryable` passed is not just a `struct`:

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex>  Sort.run(queryable, %{})
      #Ecto.Query<from p in "parents">

  When rummage `struct` passed has the key `"sort"`, but with a value of `{}`, `""`
  or `[]` it simply returns the `queryable` itself:

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> Sort.run(Parent, %{"sort" => {}})
      Parent

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> Sort.run(Parent, %{"sort" => ""})
      Parent

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> Sort.run(Parent, %{"sort" => %{}})
      Parent

  When rummage `struct` passed has the key `"sort"`, but empty associations array
  it just orders it by the passed `queryable`:

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => %{"assoc" => [], "field" => "field_1.asc"}}
      %{"sort" => %{"assoc" => [],
        "field" => "field_1.asc"}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Sort.run(queryable, rummage)
      #Ecto.Query<from p in "parents", order_by: [asc: p.field_1]>

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => %{"assoc" => [], "field" => "field_1.desc"}}
      %{"sort" => %{"assoc" => [],
        "field" => "field_1.desc"}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Sort.run(queryable, rummage)
      #Ecto.Query<from p in "parents", order_by: [desc: p.field_1]>

  When no `order` is specified, it returns the `queryable` itself:

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => %{"assoc" => [], "field" => "field_1"}}
      %{"sort" => %{"assoc" => [],
        "field" => "field_1"}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Sort.run(queryable, rummage)
      #Ecto.Query<from p in "parents">


  When rummage `struct` passed has the key `"sort"`, with `field` and `order`
  it returns a sorted version of the `queryable` passed in as the argument:

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => %{"assoc" => ["parent", "parent"], "field" => "field_1.asc"}}
      %{"sort" => %{"assoc" => ["parent", "parent"], "field" => "field_1.asc"}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Sort.run(queryable, rummage)
      #Ecto.Query<from p0 in "parents", join: p1 in assoc(p0, :parent), join: p2 in assoc(p1, :parent), order_by: [asc: p2.field_1]>


      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => %{"assoc" => ["parent", "parent"], "field" => "field_1.desc"}}
      %{"sort" => %{"assoc" => ["parent", "parent"], "field" => "field_1.desc"}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Sort.run(queryable, rummage)
      #Ecto.Query<from p0 in "parents", join: p1 in assoc(p0, :parent), join: p2 in assoc(p1, :parent), order_by: [desc: p2.field_1]>

  When no `order` is specified even with the associations, it returns the `queryable` itself:

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => %{"assoc" => ["parent", "parent"], "field" => "field_1"}}
      %{"sort" => %{"assoc" => ["parent", "parent"],
        "field" => "field_1"}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Sort.run(queryable, rummage)
      #Ecto.Query<from p0 in "parents", join: p1 in assoc(p0, :parent), join: p2 in assoc(p1, :parent)>

  # When rummage `struct` passed has `case-insensitive` sort, it returns
  # a sorted version of the `queryable` with `case_insensitive` arguments:

      iex> alias Rummage.Ecto.Hooks.Sort
      iex> import Ecto.Query
      iex> rummage = %{"sort" => %{"assoc" => ["parent", "parent"], "field" => "field_1.asc.ci"}}
      %{"sort" => %{"assoc" => ["parent", "parent"], "field" => "field_1.asc.ci"}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Sort.run(queryable, rummage)
      #Ecto.Query<from p0 in "parents", join: p1 in assoc(p0, :parent), join: p2 in assoc(p1, :parent), order_by: [asc: fragment("lower(?)", p2.field_1)]>
  """
  @spec run(Ecto.Query.t, map) :: {Ecto.Query.t, map}
  def run(queryable, rummage) do
    case Map.get(rummage, "sort") do
      a when a in [nil, [], {}, [""], "", %{}] -> queryable
      sort_params ->
        sort_params = case sort_params["assoc"] do
          s when s in [nil, ""] -> Map.put(sort_params, "assoc", [])
          _ -> sort_params
        end

        case Regex.match?(~r/\w.ci+$/, sort_params["field"]) do
          true ->
            order_param = sort_params["field"]
              |> String.split(".")
              |> Enum.drop(-1)
              |> Enum.join(".")

            sort_params = {sort_params["assoc"], order_param}

            handle_sort(queryable, sort_params, true)
          _ -> handle_sort(queryable, {sort_params["assoc"], sort_params["field"]})
        end
    end
  end

  defp handle_sort(queryable, sort_params, ci \\ false) do
    order_param = sort_params
      |> elem(1)

    association_names = sort_params
      |> elem(0)

    association_names
    |> Enum.reduce(queryable, &join_by_association(&1, &2))
    |> handle_ordering(order_param, ci)
  end

  defmacrop case_insensitive(field) do
    quote do
      fragment("lower(?)", unquote(field))
    end
  end

  defp handle_ordering(queryable, order_param, ci) do
    case Regex.match?(~r/\w.asc+$/, order_param)
      or Regex.match?(~r/\w.desc+$/, order_param) do
      true ->
        parsed_field = order_param
          |> String.split(".")
          |> Enum.drop(-1)
          |> Enum.join(".")

        order_type = order_param
          |> String.split(".")
          |> Enum.at(-1)

        queryable |> order_by_assoc(order_type, parsed_field, ci)
       _ -> queryable
    end
  end

  defp join_by_association(association, queryable) do
    join(queryable, :inner, [..., p1], p2 in assoc(p1, ^String.to_atom(association)))
  end

  defp order_by_assoc(queryable, order_type, parsed_field, false) do
    order_by(queryable, [p0, ..., p2], [{^String.to_atom(order_type), field(p2, ^String.to_atom(parsed_field))}])
  end

  defp order_by_assoc(queryable, order_type, parsed_field, true) do
    order_by(queryable, [p0, ..., p2], [{^String.to_atom(order_type), case_insensitive(field(p2, ^String.to_atom(parsed_field)))}])
  end
end

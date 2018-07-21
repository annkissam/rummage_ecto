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

  searched_queryable = Search.run(Parent, %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "like", "search_term" => "field_!"}}})

  ```

  For a case-insensitive search:

  This returns a `queryable` which upon running will give a list of `Parent`(s)
  searched by ascending case insensitive `field_1`.

  Keep in mind that `case_insensitive` can only be called for `text` fields

  ```elixir
  alias Rummage.Ecto.Hooks.Search

  searched_queryable = Search.run(Parent, %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "ilike", "search_term" => "field_!"}}})

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
    default_search: CustomHook
  ```

  The `CustomHook` must implement `behaviour `Rummage.Ecto.Hook`. For examples of `CustomHook`, check out some
    `custom_hooks` that are shipped with elixir: `Rummage.Ecto.CustomHooks.SimpleSearch`, `Rummage.Ecto.CustomHooks.SimpleSort`,
    Rummage.Ecto.CustomHooks.SimplePaginate
  """

  import Ecto.Query

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
      iex> Search.run(Parent, %{"search" => %{}})
      Parent

  When rummage `struct` passed has the key "search", with `field`, `associations`
  `search_type` and `term` it returns a searched version of the `queryable` passed in
  as the argument:

  When `associations` is an empty `list`:
    When rummage `struct` passed has `search_type` of `like`, it returns
    a searched version of the `queryable` with `like` search query:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "like", "search_term" => "field_!"}}}
        %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "like", "search_term" => "field_!"}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in subquery(from p in "parents"), where: like(p.field_1, ^"field_!")>

    When rummage `struct` passed has `search_type` of `ilike` (case insensitive), it returns
    a searched version of the `queryable` with `ilike` search query:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "ilike", "search_term" => "field_!"}}}
        %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "ilike", "search_term" => "field_!"}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in subquery(from p in "parents"), where: ilike(p.field_1, ^"field_!")>

    When rummage `struct` passed has `search_type` of `eq`, it returns
    a searched version of the `queryable` with `==` search query:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "eq", "search_term" => "field_!"}}}
        %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "eq", "search_term" => "field_!"}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in subquery(from p in "parents"), where: p.field_1 == ^"field_!">

    When rummage `struct` passed has `search_type` of `gt`, it returns
    a searched version of the `queryable` with `>` search query:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "gt", "search_term" => "field_!"}}}
        %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "gt", "search_term" => "field_!"}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in subquery(from p in "parents"), where: p.field_1 > ^"field_!">

    When rummage `struct` passed has `search_type` of `lt`, it returns
    a searched version of the `queryable` with `<` search query:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "lt", "search_term" => "field_!"}}}
        %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "lt", "search_term" => "field_!"}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in subquery(from p in "parents"), where: p.field_1 < ^"field_!">

    When rummage `struct` passed has `search_type` of `gteq`, it returns
    a searched version of the `queryable` with `>=` search query:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "gteq", "search_term" => "field_!"}}}
        %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "gteq", "search_term" => "field_!"}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in subquery(from p in "parents"), where: p.field_1 >= ^"field_!">

    When rummage `struct` passed has `search_type` of `lteq`, it returns
    a searched version of the `queryable` with `<=` search query:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "lteq", "search_term" => "field_!"}}}
        %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "lteq", "search_term" => "field_!"}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in subquery(from p in "parents"), where: p.field_1 <= ^"field_!">

  When `associations` is not an empty `list`:
    When rummage `struct` passed has `search_type` of `like`, it returns
    a searched version of the `queryable` with `like` search query:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => ["parent", "parent"], "search_type" => "like", "search_term" => "field_!"}}}
        %{"search" => %{"field_1" => %{"assoc" => ["parent", "parent"], "search_type" => "like", "search_term" => "field_!"}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p0 in subquery(from p in "parents"), join: p1 in assoc(p0, :parent), join: p2 in assoc(p1, :parent), where: like(p2.field_1, ^"field_!")>

    When rummage `struct` passed has `search_type` of `lteq`, it returns
    a searched version of the `queryable` with `<=` search query:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => ["parent", "parent"], "search_type" => "lteq", "search_term" => "field_!"}}}
        %{"search" => %{"field_1" => %{"assoc" => ["parent", "parent"], "search_type" => "lteq", "search_term" => "field_!"}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p0 in subquery(from p in "parents"), join: p1 in assoc(p0, :parent), join: p2 in assoc(p1, :parent), where: p2.field_1 <= ^"field_!">

    When rummage `struct` passed has an empty string as `search_term`, it returns the `queryable` itself:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => ["parent", "parent"], "search_type" => "lteq", "search_term" => ""}}}
        %{"search" => %{"field_1" => %{"assoc" => ["parent", "parent"], "search_type" => "lteq", "search_term" => ""}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in "parents">

    When rummage `struct` passed has nil as `search_term`, it returns the `queryable` itself:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => ["parent", "parent"], "search_type" => "lteq", "search_term" => nil}}}
        %{"search" => %{"field_1" => %{"assoc" => ["parent", "parent"], "search_type" => "lteq", "search_term" => nil}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in "parents">

    When rummage `struct` passed has an empty array as `search_term`, it returns the `queryable` itself:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => ["parent", "parent"], "search_type" => "lteq", "search_term" => []}}}
        %{"search" => %{"field_1" => %{"assoc" => ["parent", "parent"], "search_type" => "lteq", "search_term" => []}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in "parents">

  When `associations` is an empty `string`:
    When rummage `struct` passed has `search_type` of `like`, it returns
    a searched version of the `queryable` with `like` search query:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => "", "search_type" => "like", "search_term" => "field_!"}}}
        %{"search" => %{"field_1" => %{"assoc" => "", "search_type" => "like", "search_term" => "field_!"}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in subquery(from p in "parents"), where: like(p.field_1, ^"field_!")>


    When rummage `struct` passed has `search_type` of `is_nil`, it returns
    a searched version of the `queryable` with `IS NULL` search query:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "is_nil", "search_term" => "true"}}}
        %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "is_nil", "search_term" => "true"}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in subquery(from p in "parents"), where: is_nil(p.field_1)>

    When rummage `struct` passed has `search_type` of `between`, it returns
    a searched version of the `queryable` with `BETWEEN` search query:

        iex> alias Rummage.Ecto.Hooks.Search
        iex> import Ecto.Query
        iex> rummage = %{"search" => %{"field_1" => %{"assoc" => [], "search_type" => "between", "search_term" => ["first", "last"]}}}
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> Search.run(queryable, rummage)
        #Ecto.Query<from p in subquery(from p in "parents"), where: p.field_1 >= ^"first", where: p.field_1 <= ^"last">
  """
  @spec run(Ecto.Query.t(), map) :: {Ecto.Query.t(), map}
  def run(queryable, rummage) do
    search_params = Map.get(rummage, "search")

    case search_params do
      a when a in [nil, [], {}, [""], "", %{}] -> queryable
      _ -> handle_search(queryable, search_params)
    end
  end

  @doc """
  Implementation of `before_hook` for `Rummage.Ecto.Hooks.Search`. This just returns back `rummage` at this point.
  It doesn't matter what `queryable` or `opts` are, it just returns back `rummage`.

  ## Examples
      iex> alias Rummage.Ecto.Hooks.Search
      iex> Search.before_hook(Parent, %{}, %{})
      %{}
  """
  @spec before_hook(Ecto.Query.t(), map, map) :: map
  def before_hook(_queryable, rummage, _opts), do: rummage

  defp handle_search(queryable, search_params) do
    search_params
    |> Map.to_list()
    |> Enum.reduce(queryable, &search_queryable(&1, &2))
  end

  defp search_queryable(param, queryable) do
    field =
      param
      |> elem(0)
      |> String.to_atom()

    field_params =
      param
      |> elem(1)

    association_names =
      case field_params["assoc"] do
        a when a in [nil, "", []] -> []
        assoc -> assoc
      end

    search_type = field_params["search_type"]
    search_term = field_params["search_term"]

    case search_term do
      s when s in [nil, "", []] ->
        queryable

      _ ->
        queryable = from(e in subquery(queryable))

        association_names
        |> Enum.reduce(queryable, &join_by_association(&1, &2))
        |> BuildSearchQuery.run(field, search_type, search_term)
    end
  end

  defp join_by_association(association, queryable) do
    join(queryable, :inner, [..., p1], p2 in assoc(p1, ^String.to_atom(association)))
  end
end

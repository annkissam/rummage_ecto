defmodule Rummage.Ecto.Hook.Paginate do
  @moduledoc """
  `Rummage.Ecto.Hook.Paginate` is the default pagination hook that comes with
  `Rummage.Ecto`.

  This module provides a operations that can add pagination functionality to
  a pipeline of `Ecto` queries. This module works by taking a `per_page`, which
  it uses to add a `limit` to the query and by setting the `offset` using the
  `page` variable, which signifies the current page of entries to be displayed.


  NOTE: This module doesn't return a list of entries, but a `Ecto.Query.t`.
  This module `uses` `Rummage.Ecto.Hook`.

  _____________________________________________________________________________

  # ABOUT:

  ## Arguments:

  This Hook expects a `queryable` (an `Ecto.Queryable`) and
  `paginate_params` (a `Map`). The map should be in the format:
  `%{per_page: 10, page: 1}`

  Details:

  * `per_page`: Specifies the entries in each page.
  * `page`: Specifies the `page` number.


  For example, if we want to paginate products, we would
  do the following:

  ```elixir
  Rummage.Ecto.Hook.Paginate.run(Product, %{per_page: 10, page: 1})
  ```

  _____________________________________________________________________________

  # ASSUMPTIONS/NOTES:

  NONE: This Hook should work for all the `Schema` types. Whether the schema has
  a primary_key or not, this should handle that.

  _____________________________________________________________________________

  ## USAGE:

  To add pagination to a `Ecto.Queryable`, simply do the following:

  ```ex
  Rummage.Ecto.Hook.Paginate.run(queryable, %{per_page: 10, page: 2})
  ```

  ## Overriding:

  This module can be overridden with a custom module while using `Rummage.Ecto`
  in `Ecto` struct module.

  In the `Ecto` module:
  ```elixir
  Rummage.Ecto.rummage(queryable, rummage, paginate: CustomHook)
  ```

  OR

  Globally for all models in `config.exs`:
  ```elixir
  config :rummage_ecto,
    Rummage.Ecto,
   .paginate: CustomHook
  ```

  The `CustomHook` must use `Rummage.Ecto.Hook`. For examples of `CustomHook`,
  check out some `custom_hooks` that are shipped with `Rummage.Ecto`:
  `Rummage.Ecto.CustomHook.SimpleSearch`, `Rummage.Ecto.CustomHook.SimpleSort`,
    Rummage.Ecto.CustomHook.SimplePaginate
  """

  use Rummage.Ecto.Hook

  import Ecto.Query

  @expected_keys ~w{per_page page}a
  @err_msg ~s{Error in params, No values given for keys: }

  @per_page 10

  @doc """
  This is the callback implementation of `Rummage.Ecto.Hook.run/2`.

  Builds a paginate `Ecto.Query.t` on top of a given `Ecto.Query.t` variable
  with given `params`.

  Besides an `Ecto.Query.t` an `Ecto.Schema` module can also be passed as it
  implements `Ecto.Queryable`

  Params is a `Map` which is expected to have the keys `#{Enum.join(@expected_keys, ", ")}`.

  If an expected key isn't given, a `Runtime Error` is raised.

  ## Examples
  When an empty map is passed as `params`:

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> import Ecto.Query
      iex> Paginate.run(Parent, %{})
      ** (RuntimeError) Error in params, No values given for keys: per_page, page

  When a non-empty map is passed as `params`, but with a missing key:

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> import Ecto.Query
      iex> Paginate.run(Parent, %{per_page: 10})
      ** (RuntimeError) Error in params, No values given for keys: page

  When a valid map of params is passed with an `Ecto.Schema` module:

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> import Ecto.Query
      iex> Paginate.run(Rummage.Ecto.Product, %{per_page: 10, page: 1})
      #Ecto.Query<from p in Rummage.Ecto.Product, limit: ^10, offset: ^0>

  When the `queryable` passed is an `Ecto.Query` variable:

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> import Ecto.Query
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> Paginate.run(queryable, %{per_page: 10, page: 2})
      #Ecto.Query<from p in "products", limit: ^10, offset: ^10>


  More examples:

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> import Ecto.Query
      iex> rummage = %{per_page: 1, page: 1}
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> Paginate.run(queryable, rummage)
      #Ecto.Query<from p in "products", limit: ^1, offset: ^0>

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> import Ecto.Query
      iex> rummage = %{per_page: 5, page: 2}
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> Paginate.run(queryable, rummage)
      #Ecto.Query<from p in "products", limit: ^5, offset: ^5>

  """
  @spec run(Ecto.Query.t(), map()) :: Ecto.Query.t()
  def run(queryable, paginate_params) do
    :ok = validate_params(paginate_params)

    handle_paginate(queryable, paginate_params)
  end

  # Helper function which handles addition of paginated query on top of
  # the sent queryable variable
  defp handle_paginate(queryable, paginate_params) do
    per_page = Map.get(paginate_params, :per_page)
    page = Map.get(paginate_params, :page)
    offset = per_page * (page - 1)

    queryable
    |> limit(^per_page)
    |> offset(^offset)
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

  This function takes an `Ecto.Query.t` or `queryable`, `paginate_params` which
  will be passed to the `run/2` function, but also takes a list of options,
  `opts`.

  The function expects `opts` to include a `repo` key which points to the
  `Ecto.Repo` which will be used to calculate the `total_count` and `max_page`
  for this paginate hook module.


  ## Examples

  When a `repo` isn't passed in `opts` it gives an error:

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> alias Rummage.Ecto.Category
      iex> Paginate.format_params(Category, %{per_page: 1, page: 1}, [])
      ** (RuntimeError) Expected key `repo` in `opts`, got []

  When `paginate_params` given aren't valid, it uses defaults to populate params:

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> alias Rummage.Ecto.Category
      iex> Ecto.Adapters.SQL.Sandbox.checkout(Rummage.Ecto.Repo)
      iex> Paginate.format_params(Category, %{}, [repo: Rummage.Ecto.Repo])
      %{max_page: 0, page: 1, per_page: 10, total_count: 0}

  When `paginate_params` and `opts` given are valid:

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> alias Rummage.Ecto.Category
      iex> paginate_params = %{
      ...>   per_page: 1,
      ...>   page: 1
      ...> }
      iex> repo = Rummage.Ecto.Repo
      iex> Ecto.Adapters.SQL.Sandbox.checkout(repo)
      iex> Paginate.format_params(Category, paginate_params, [repo: repo])
      %{max_page: 0, page: 1, per_page: 1, total_count: 0}

  When `paginate_params` and `opts` given are valid:

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> alias Rummage.Ecto.Category
      iex> paginate_params = %{
      ...>   per_page: 1,
      ...>   page: 1
      ...> }
      iex> repo = Rummage.Ecto.Repo
      iex> Ecto.Adapters.SQL.Sandbox.checkout(repo)
      iex> repo.insert!(%Category{name: "name"})
      iex> repo.insert!(%Category{name: "name2"})
      iex> Paginate.format_params(Category, paginate_params, [repo: repo])
      %{max_page: 2, page: 1, per_page: 1, total_count: 2}

  When `paginate_params` and `opts` given are valid and when the `queryable`
  passed has a `primary_key` defaulted to `id`.

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> alias Rummage.Ecto.Category
      iex> paginate_params = %{
      ...>   per_page: 1,
      ...>   page: 1
      ...> }
      iex> repo = Rummage.Ecto.Repo
      iex> Ecto.Adapters.SQL.Sandbox.checkout(repo)
      iex> repo.insert!(%Category{name: "name"})
      iex> repo.insert!(%Category{name: "name2"})
      iex> Paginate.format_params(Category, paginate_params, [repo: repo])
      %{max_page: 2, page: 1, per_page: 1, total_count: 2}

  When `paginate_params` and `opts` given are valid and when the `queryable`
  passed has a custom `primary_key`.

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> alias Rummage.Ecto.Product
      iex> paginate_params = %{
      ...>   per_page: 1,
      ...>   page: 1
      ...> }
      iex> repo = Rummage.Ecto.Repo
      iex> Ecto.Adapters.SQL.Sandbox.checkout(repo)
      iex> repo.insert!(%Product{internal_code: "100"})
      iex> repo.insert!(%Product{internal_code: "101"})
      iex> Paginate.format_params(Product, paginate_params, [repo: repo])
      %{max_page: 2, page: 1, per_page: 1, total_count: 2}

  When `paginate_params` and `opts` given are valid and when the `queryable`
  passed has a custom `primary_key`.

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> alias Rummage.Ecto.Employee
      iex> paginate_params = %{
      ...>   per_page: 1,
      ...>   page: 1
      ...> }
      iex> repo = Rummage.Ecto.Repo
      iex> Ecto.Adapters.SQL.Sandbox.checkout(repo)
      iex> repo.insert!(%Employee{first_name: "First"})
      iex> repo.insert!(%Employee{first_name: "Second"})
      iex> Paginate.format_params(Employee, paginate_params, [repo: repo])
      %{max_page: 2, page: 1, per_page: 1, total_count: 2}

  When `paginate_params` and `opts` given are valid and when the `queryable`
  passed is not a `Ecto.Schema` module, but an `Ecto.Query.t`.

      iex> alias Rummage.Ecto.Hook.Paginate
      iex> alias Rummage.Ecto.Employee
      iex> paginate_params = %{
      ...>   per_page: 1,
      ...>   page: 1
      ...> }
      iex> repo = Rummage.Ecto.Repo
      iex> Ecto.Adapters.SQL.Sandbox.checkout(repo)
      iex> repo.insert!(%Employee{first_name: "First"})
      iex> repo.insert!(%Employee{first_name: "Second"})
      iex> import Ecto.Query
      iex> queryable = from u in Employee, where: u.first_name == "First"
      iex> Paginate.format_params(queryable, paginate_params, [repo: repo])
      %{max_page: 1, page: 1, per_page: 1, total_count: 1}

  """
  @spec format_params(Ecto.Query.t(), map() | atom(), keyword()) :: map()
  def format_params(queryable, {paginate_scope, page}, opts) do
    module = get_module(queryable)
    name = :"__rummage_paginate_#{paginate_scope}"
    paginate_params = case function_exported?(module, name, 1) do
      true -> apply(module, name, [page])
      _ -> raise "No scope `#{paginate_scope}` of type paginate defined in the #{module}"
    end

    format_params(queryable, paginate_params, opts)
  end
  def format_params(queryable, paginate_params, opts) do
    paginate_params = populate_params(paginate_params, opts)

    case Keyword.get(opts, :repo) do
      nil -> raise "Expected key `repo` in `opts`, got #{inspect(opts)}"
      repo -> get_params(queryable, paginate_params, repo)
    end
  end

  # Helper function that populate the list of params based on
  # @expected_keys list
  defp populate_params(params, opts) do
    params
    |> Map.put_new(:per_page, Keyword.get(opts, :per_page, @per_page))
    |> Map.put_new(:page, 1)
  end

  # Helper function which gets formatted list of params including
  # page, per_page, total_count and max_page keys
  defp get_params(queryable, paginate_params, repo) do
    per_page = Map.get(paginate_params, :per_page)
    total_count = get_total_count(queryable, repo)
    max_page = total_count
      |> (& &1 / per_page).()
      |> Float.ceil()
      |> trunc()

    %{page: Map.get(paginate_params, :page),
      per_page: per_page, total_count: total_count, max_page: max_page}
  end

  # Helper function which gets total count of a queryable based on
  # the given repo.
  # This excludes operations such as select, preload and order_by
  # to make the query more effectient
  defp get_total_count(queryable, repo) do
    queryable
    |> exclude(:select)
    |> exclude(:preload)
    |> exclude(:order_by)
    |> get_count(repo, pk(queryable))
  end

  # This function gets count of a query and repo passed.
  # When primary key passed is nil, it just gets all the elements
  # and counts them, but when a primary key is passed it just counts
  # the distinct primary keys
  defp get_count(query, repo, nil) do
    repo
    |> apply(:all, [distinct(query, :true)])
    |> Enum.count()
  end
  defp get_count(query, repo, pk) do
    query = select(query, [s], count(field(s, ^pk), :distinct))
    hd(apply(repo, :all, [query]))
  end

  # Helper function which returns the primary key associated with a
  # Queryable.
  defp pk(queryable) do
    schema = schema_from_query(queryable)

    case schema.__schema__(:primary_key) do
      [] -> nil
      list -> hd(list)
    end
  end

  defp schema_from_query(queryable) do
    case queryable do
      %{from: %{query: subquery}} -> schema_from_query(subquery)
      %{from: {_, schema}} -> schema
      _ -> queryable
    end
  end
end

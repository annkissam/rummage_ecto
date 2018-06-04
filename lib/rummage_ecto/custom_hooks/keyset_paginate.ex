defmodule Rummage.Ecto.CustomHook.KeysetPaginate do
  @moduledoc """
  `Rummage.Ecto.CustomHook.KeysetPaginate` is an example of a Custom Hook that
  comes with `Rummage.Ecto`.

  This module uses `keyset` pagination to add a pagination query expression
  on top a given `Ecto.Queryable`.

  For more information on Keyset Pagination, check this
  [article](http://use-the-index-luke.com/no-offset)

  NOTE: This module doesn't return a list of entries, but a `Ecto.Query.t`.
  This module `uses` `Rummage.Ecto.Hook`.

  _____________________________________________________________________________

  # ABOUT:

  ## Arguments:

  This Hook expects a `queryable` (an `Ecto.Queryable`) and
  `paginate_params` (a `Map`). The map should be in the format:
  `%{per_page: 10, page: 1, last_seen_pk: 10, pk: :id}`

  Details:

  * `per_page`: Specifies the entries in each page.
  * `page`: Specifies the `page` number.
  * `last_seen_pk`: Specifies the primary_key value of last_seen entry,
                    This hook uses this entry instead of offset.
  * `pk`: Specifies what's the `primary_key` for the entries being paginated.
          Cannot be `nil`


  For example, if we want to paginate products (primary_key = :id), we would
  do the following:

  ```elixir
  Rummage.Ecto.CustomHook.KeysetPaginate.run(Product,
    %{per_page: 10, page: 1, last_seen_pk: 10, pk: :id})
  ```

  ## When to Use KeysetPaginate?

  - Keyset Pagination is mainly here to make pagination faster for complex
  pages. It is recommended that you use `Rummage.Ecto.Hook.Paginate` for a
  simple pagination operation, as this module has a lot of assumptions and
  it's own ordering on top of the given query.

  NOTE: __It is not recommended to use this with the native sort hook__

  _____________________________________________________________________________

  # ASSUMPTIONS/NOTES:

  * This Hook assumes that the querried `Ecto.Schema` has a `primary_key`.
  * This Hook also orders the query by ascending `primary_key`

  _____________________________________________________________________________

  # USAGE

  ```elixir
  alias Rummage.Ecto.CustomHook.KeysetPaginate

  queryable = KeysetPaginate.run(Parent,
    %{per_page: 10, page: 1, last_seen_pk: 10, pk: :id})
  ```

  This module can be used by overriding the default module. This can be done
  in the following ways:

  In the `Rummage.Ecto` call:
  ```elixir
  Rummage.Ecto.rummage(queryable, rummage,
    paginate: Rummage.Ecto.CustomHook.KeysetPaginate)
  ```

  OR

  Globally for all models in `config.exs`:
  ```elixir
  config :my_app,
    Rummage.Ecto,
    paginate: Rummage.Ecto.CustomHook.KeysetPaginate
  ```

  OR

  When `using` Rummage.Ecto with an `Ecto.Schema`:
  ```elixir
  defmodule MySchema do
    use Rummage.Ecto, repo: SomeRepo,
      paginate: Rummage.Ecto.CustomHook.KeysetPaginate
  end
  ```
  """

  use Rummage.Ecto.Hook

  import Ecto.Query

  @expected_keys ~w(per_page page last_seen_pk pk)a
  @err_msg "Error in params, No values given for keys: "

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

      iex> alias Rummage.Ecto.CustomHook.KeysetPaginate
      iex> KeysetPaginate.run(Parent, %{})
      ** (RuntimeError) Error in params, No values given for keys: per_page, page, last_seen_pk, pk

  When a non-empty map is passed as `params`, but with a missing key:

      iex> alias Rummage.Ecto.CustomHook.KeysetPaginate
      iex> KeysetPaginate.run(Parent, %{per_page: 10})
      ** (RuntimeError) Error in params, No values given for keys: page, last_seen_pk, pk

  When a valid map of params is passed with an `Ecto.Schema` module:

      iex> alias Rummage.Ecto.CustomHook.KeysetPaginate
      iex> params = %{per_page: 10, page: 1, last_seen_pk: 0, pk: :id}
      iex> KeysetPaginate.run(Rummage.Ecto.Product, params)
      #Ecto.Query<from p in Rummage.Ecto.Product, where: p.id > ^0, limit: ^10>

  When the `queryable` passed is an `Ecto.Query` variable:

      iex> alias Rummage.Ecto.CustomHook.KeysetPaginate
      iex> import Ecto.Query
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> params = %{per_page: 10, page: 1, last_seen_pk: 0, pk: :id}
      iex> KeysetPaginate.run(queryable, params)
      #Ecto.Query<from p in "products", where: p.id > ^0, limit: ^10>


  More examples:

      iex> alias Rummage.Ecto.CustomHook.KeysetPaginate
      iex> import Ecto.Query
      iex> params = %{per_page: 5, page: 5, last_seen_pk: 25, pk: :id}
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> KeysetPaginate.run(queryable, params)
      #Ecto.Query<from p in "products", where: p.id > ^25, limit: ^5>

      iex> alias Rummage.Ecto.CustomHook.KeysetPaginate
      iex> import Ecto.Query
      iex> params = %{per_page: 5, page: 1, last_seen_pk: 0, pk: :some_id}
      iex> queryable = from u in "products"
      #Ecto.Query<from p in "products">
      iex> KeysetPaginate.run(queryable, params)
      #Ecto.Query<from p in "products", where: p.some_id > ^0, limit: ^5>

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
    last_seen_pk = Map.get(paginate_params, :last_seen_pk)
    pk = Map.get(paginate_params, :pk)

    queryable
    |> where([p1, ...], field(p1, ^pk) > ^last_seen_pk)
    |> limit(^per_page)
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

      iex> alias Rummage.Ecto.CustomHook.KeysetPaginate
      iex> alias Rummage.Ecto.Category
      iex> KeysetPaginate.format_params(Category, %{per_page: 1, page: 1}, [])
      ** (RuntimeError) Expected key `repo` in `opts`, got []

  When `paginate_params` given aren't valid, it uses defaults to populate params:

      iex> alias Rummage.Ecto.CustomHook.KeysetPaginate
      iex> alias Rummage.Ecto.Category
      iex> Ecto.Adapters.SQL.Sandbox.checkout(Rummage.Ecto.Repo)
      iex> KeysetPaginate.format_params(Category, %{}, [repo: Rummage.Ecto.Repo])
      %{max_page: 0, page: 1, per_page: 10, total_count: 0, pk: :id,
        last_seen_pk: 0}

  When `paginate_params` and `opts` given are valid:

      iex> alias Rummage.Ecto.CustomHook.KeysetPaginate
      iex> alias Rummage.Ecto.Category
      iex> paginate_params = %{
      ...>   per_page: 1,
      ...>   page: 1
      ...> }
      iex> repo = Rummage.Ecto.Repo
      iex> Ecto.Adapters.SQL.Sandbox.checkout(repo)
      iex> KeysetPaginate.format_params(Category, paginate_params, [repo: repo])
      %{max_page: 0, last_seen_pk: 0, page: 1,
        per_page: 1, total_count: 0, pk: :id}

  When `paginate_params` and `opts` given are valid:

      iex> alias Rummage.Ecto.CustomHook.KeysetPaginate
      iex> alias Rummage.Ecto.Category
      iex> paginate_params = %{
      ...>   per_page: 1,
      ...>   page: 1
      ...> }
      iex> repo = Rummage.Ecto.Repo
      iex> Ecto.Adapters.SQL.Sandbox.checkout(repo)
      iex> repo.insert!(%Category{name: "name"})
      iex> repo.insert!(%Category{name: "name2"})
      iex> KeysetPaginate.format_params(Category, paginate_params, [repo: repo])
      %{max_page: 2, last_seen_pk: 0, page: 1,
        per_page: 1, total_count: 2, pk: :id}

  When `paginate_params` and `opts` given are valid and when the `queryable`
  passed has a `primary_key` defaulted to `id`.

      iex> alias Rummage.Ecto.CustomHook.KeysetPaginate
      iex> alias Rummage.Ecto.Category
      iex> paginate_params = %{
      ...>   per_page: 1,
      ...>   page: 1
      ...> }
      iex> repo = Rummage.Ecto.Repo
      iex> Ecto.Adapters.SQL.Sandbox.checkout(repo)
      iex> repo.insert!(%Category{name: "name"})
      iex> repo.insert!(%Category{name: "name2"})
      iex> KeysetPaginate.format_params(Category, paginate_params, [repo: repo])
      %{max_page: 2, last_seen_pk: 0, page: 1,
        per_page: 1, total_count: 2, pk: :id}

  When `paginate_params` and `opts` given are valid and when the `queryable`
  passed has a custom `primary_key`.

      iex> alias Rummage.Ecto.CustomHook.KeysetPaginate
      iex> alias Rummage.Ecto.Product
      iex> paginate_params = %{
      ...>   per_page: 1,
      ...>   page: 2
      ...> }
      iex> repo = Rummage.Ecto.Repo
      iex> Ecto.Adapters.SQL.Sandbox.checkout(repo)
      iex> repo.insert!(%Product{internal_code: "100"})
      iex> repo.insert!(%Product{internal_code: "101"})
      iex> KeysetPaginate.format_params(Product, paginate_params, [repo: repo])
      %{max_page: 2, last_seen_pk: 1, page: 2,
        per_page: 1, total_count: 2, pk: :internal_code}

  """
  @spec format_params(Ecto.Query.t(), map(), keyword()) :: map()
  def format_params(queryable, paginate_params, opts) do
    paginate_params = populate_params(queryable, paginate_params, opts)

    case Keyword.get(opts, :repo) do
      nil -> raise "Expected key `repo` in `opts`, got #{inspect(opts)}"
      repo -> get_params(queryable, paginate_params, repo)
    end
  end

  # Helper function that populate the list of params based on
  # @expected_keys list
  defp populate_params(queryable, params, opts) do
    params = params
      |> Map.put_new(:per_page, Keyword.get(opts, :per_page, @per_page))
      |> Map.put_new(:pk, pk(queryable))
      |> Map.put_new(:page, 1)

    Map.put_new(params, :last_seen_pk, get_last_seen(params))
  end

  # Helper function which gets the default last_seen_pk from
  # page and per_page
  defp get_last_seen(params) do
    Map.get(params, :per_page) * (Map.get(params, :page) - 1)
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

    %{page: Map.get(paginate_params, :page), pk: Map.get(paginate_params, :pk),
      last_seen_pk: Map.get(paginate_params, :last_seen_pk),
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
  # A primary key must be passed and it just counts
  # the distinct primary keys
  defp get_count(query, repo, pk) do
    query = select(query, [s], count(field(s, ^pk), :distinct))
    hd(apply(repo, :all, [query]))
  end

  # Helper function which returns the primary key associated with a
  # Queryable.
  defp pk(queryable) do
    schema = is_map(queryable) && elem(queryable.from, 1) || queryable

    case schema.__schema__(:primary_key) do
      [] -> nil
      list -> hd(list)
    end
  end
end

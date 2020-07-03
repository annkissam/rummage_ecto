defmodule Rummage.Ecto do
  @moduledoc """
  Rummage.Ecto is a light weight, but powerful framework that can be used to alter Ecto
  queries with Search, Sort and Paginate operations.

  It accomplishes the above operations by using `Hooks`, which are modules that
  implement `Rummage.Ecto.Hook` behavior. Each operation: Search, Sort and Paginate
  have their hooks defined in Rummage. By doing this, we have made rummage completely
  configurable. For example, if you don't like one of the implementations of Rummage,
  but like the other two, you can configure Rummage to not use it.

  If you want to check a sample application that uses Rummage, please check
  [this link](https://github.com/aditya7iyengar/rummage_ecto_example).

  Usage:

  ```elixir
  defmodule Rummage.Ecto.Category do
    use Ecto.Schema
    use Rummage.Ecto

    schema "categories" do
      field :name, :string
    end

  end
  ```

  This allows you to do:

      iex> rummage = %{search: %{name: %{assoc: [], search_type: :ilike, search_term: "field_!"}}}
      iex> {queryable, rummage} = Rummage.Ecto.Category.rummageq(Rummage.Ecto.Category, rummage)
      iex> queryable
      #Ecto.Query<from c0 in subquery(from c0 in Rummage.Ecto.Category), where: ilike(c0.name, ^"%field_!%")>
      iex> rummage
      %{search: %{name: %{assoc: [], search_expr: :where,
        search_term: "field_!", search_type: :ilike}}}

  This also allows you to do call `rummage/2` without a `queryable` which defaults
  to the module calling `rummage`, which is `Rummage.Ecto.Category` in this case:

      iex> rummage = %{search: %{name: %{assoc: [], search_type: :ilike, search_term: "field_!"}}}
      iex> {queryable, rummage} = Rummage.Ecto.Category.rummage(rummage)
      iex> queryable
      #Ecto.Query<from c0 in subquery(from c0 in Rummage.Ecto.Category), where: ilike(c0.name, ^"%field_!%")>
      iex> rummage
      %{search: %{name: %{assoc: [], search_expr: :where,
        search_term: "field_!", search_type: :ilike}}}

  """

  alias Rummage.Ecto.Config, as: RConfig

  @doc """
  This is the function which calls to the `Rummage` `hooks`.
  It is the entry-point to `Rummage.Ecto`.

  This function takes in a `queryable`, a `rummage` map and an `opts` keyword.
  Recognized `opts` keys are:

  * `repo`: If you haven't set up a `repo` at the config level or `__using__`
            level, this a way of passing `repo` to `rummage`. If you have
            already configured your app to use a default `repo` and/or
            specified the `repo` at `__using__` level, this is a way of
            overriding those defaults.

  * `per_page`: If you haven't set up a `per_page` at the config level or `__using__`
                level, this a way of passing `per_page` to `rummage`. If you have
                already configured your app to use a default `per_page` and/or
                specified the `per_page` at `__using__` level, this is a way of
                overriding those defaults.

  * `search`: If you haven't set up a `search` at the config level or `__using__`
              level, this a way of passing `search` to `rummage`. If you have
              already configured your app to use a default `search` and/or
              specified the `search` at `__using__` level, this is a way of
              overriding those defaults. This can be used to override native
              `Rummage.Ecto.Hook.Search` to a custom hook.

  * `sort`: If you haven't set up a `sort` at the config level or `__using__`
            level, this a way of passing `sort` to `rummage`. If you have
            already configured your app to use a default `sort` and/or
            specified the `sort` at `__using__` level, this is a way of
            overriding those defaults. This can be used to override native
            `Rummage.Ecto.Hook.Sort` to a custom hook.

  * `paginate`: If you haven't set up a `paginate` at the config level or `__using__`
                level, this a way of passing `paginate` to `rummage`. If you have
                already configured your app to use a default `paginate` and/or
                specified the `paginate` at `__using__` level, this is a way of
                overriding those defaults. This can be used to override native
                `Rummage.Ecto.Hook.Paginate` to a custom hook.


  ## Examples
  When no hook params are given, it just returns the queryable and the params:

      iex> import Rummage.Ecto
      iex> alias Rummage.Ecto.Product
      iex> rummage = %{}
      iex> {queryable, rummage} = rummage(Product, rummage)
      iex> rummage
      %{}
      iex> queryable
      Rummage.Ecto.Product

  When `nil` hook module is given, it just returns the queryable and the params:

      iex> import Rummage.Ecto
      iex> alias Rummage.Ecto.Product
      iex> rummage = %{paginate: %{page: 1}}
      iex> {queryable, rummage} = rummage(Product, rummage, paginate: nil)
      iex> rummage
      %{paginate: %{page: 1}}
      iex> queryable
      Rummage.Ecto.Product


  When a hook param is given, with hook module it just returns the
  `queryable` and the `params`:

      iex> import Rummage.Ecto
      iex> alias Rummage.Ecto.Product
      iex> rummage = %{paginate: %{page: 1}}
      iex> repo = Rummage.Ecto.Repo
      iex> Ecto.Adapters.SQL.Sandbox.checkout(repo)
      iex> opts = [paginate: Rummage.Ecto.Hook.Paginate, repo: repo]
      iex> {queryable, rummage} = rummage(Product, rummage, opts)
      iex> rummage
      %{paginate: %{max_page: 0, page: 1, per_page: 10, total_count: 0}}
      iex> queryable
      #Ecto.Query<from p0 in Rummage.Ecto.Product, limit: ^10, offset: ^0>


  When a hook is given, with correspondng params, it updates and returns the
  `queryable` and the `params` accordingly:

      iex> import Rummage.Ecto
      iex> alias Rummage.Ecto.Product
      iex> rummage = %{paginate: %{per_page: 1, page: 1}}
      iex> repo = Rummage.Ecto.Repo
      iex> Ecto.Adapters.SQL.Sandbox.checkout(repo)
      iex> repo.insert!(%Product{name: "name", internal_code: "100"})
      iex> repo.insert!(%Product{name: "name2", internal_code: "101"})
      iex> opts = [paginate: Rummage.Ecto.Hook.Paginate,
      ...>  repo: repo]
      iex> {queryable, rummage} = rummage(Product, rummage, opts)
      iex> rummage
      %{paginate: %{max_page: 2, page: 1, per_page: 1, total_count: 2}}
      iex> queryable
      #Ecto.Query<from p0 in Rummage.Ecto.Product, limit: ^1, offset: ^0>

  """
  @spec rummage(Ecto.Query.t(), map(), Keyword.t()) :: {Ecto.Query.t(), map()}
  def rummage(queryable, rummage, opts \\ []) do
    hooks = [
      search: Keyword.get(opts, :search, RConfig.search()),
      sort: Keyword.get(opts, :sort, RConfig.sort()),
      paginate: Keyword.get(opts, :paginate, RConfig.paginate())
    ]

    rummage = Enum.reduce(hooks, rummage, &format_hook_params(&1, &2, queryable, opts))

    {Enum.reduce(hooks, queryable, &run_hook(&1, &2, rummage)), rummage}
  end

  defp format_hook_params({_, nil}, rummage, _, _), do: rummage

  defp format_hook_params({type, hook_mod}, rummage, queryable, opts) do
    case Map.get(rummage, type) do
      nil -> rummage
      params -> Map.put(rummage, type, apply(hook_mod, :format_params, [queryable, params, opts]))
    end
  end

  defp run_hook({_, nil}, queryable, _), do: queryable

  defp run_hook({type, hook_mod}, queryable, rummage) do
    case Map.get(rummage, type) do
      nil -> queryable
      params -> apply(hook_mod, :run, [queryable, params])
    end
  end

  @doc """
  This macro allows an `Ecto.Schema` to leverage rummage's features with
  ease. This macro defines a function `rummage/2` which can be called on
  the Module `using` this which delegates to `Rummage.Ecto.rummage/3`, but
  before doing that it resolves the options with default values for `repo`,
  `search` hook, `sort` hook and `paginate` hook. If `rummage/2` is called with
  those options in form of keys given to the last argument `opts`, then it
  sets those keys to what's given else it delegates it to the defaults
  specficied by `__using__` macro. If no defaults are specified, then it
  further delegates it to configurations.

  The function `rummage/2` takes in `rummage params` and `opts` and calls
  `Rummage.Ecto.rummage/3` with whatever schema is calling it as the
  `queryable`.

  This macro also defines a function `rummageq/3` where q implies `queryable`.
  Therefore this function can take a `queryable` as the first argument.

  In this way this macro makes it very easy to use `Rummage.Ecto`.

  ## Usage:

  ### Basic Usage where a default repo is specified as options to the macro.
  ```elixir
  defmodule MyApp.MySchema do
    use Ecto.Schema
    use Rummage.Ecto, repo: MyApp.Repo, per_page: 10
  end
  ```

  ### Advanced Usage where search and sort hooks are overrident for this module.
  ```elixir
  defmodule MyApp.MySchema do
    use Ecto.Schema
    use Rummage.Ecto, repo: MyApp.Repo, per_page: 10,
                      search: CustomSearchModule,
                      sort: CustomSortModule
  end

  This allows you do just do `MyApp.Schema.rummage(rummage_params)` with specific
  `rummage_params` and add `Rummage.Ecto`'s power to your schema.
  ```

  """
  defmacro __using__(opts) do
    quote do
      alias Rummage.Ecto.Config, as: RConfig

      def rummage(rummage, opts \\ []) do
        Rummage.Ecto.rummage(__MODULE__, rummage, uniq_merge(opts, defaults()))
      end

      def rummageq(queryable, rummage, opts \\ []) do
        Rummage.Ecto.rummage(queryable, rummage, uniq_merge(opts, defaults()))
      end

      defp defaults() do
        keys = ~w{repo per_page search sort paginate}a
        Enum.map(keys, &get_defs/1)
      end

      defp get_defs(key) do
        app = Application.get_application(__MODULE__)
        {key, Keyword.get(unquote(opts), key, apply(RConfig, key, [app]))}
      end

      defp uniq_merge(keyword1, keyword2) do
        keyword2
        |> Keyword.merge(keyword1)
        |> Keyword.new()
      end
    end
  end
end

defmodule Rummage.Ecto do
  @moduledoc ~S"""
  Rummage.Ecto is a light weight, but powerful framework that can be used to alter Ecto
  queries with Search, Sort and Paginate operations.

  It accomplishes the above operations by using `Hooks`, which are modules that
  implement `Rumamge.Ecto.Hook` behavior. Each operation: Search, Sort and Paginate
  have their hooks defined in Rummage. By doing this, we have made rummage completely
  configurable. For example, if you don't like one of the implementations of Rummage,
  but like the other two, you can configure Rummage to not use it.

  If you want to check a sample application that uses Rummage, please check
  [this link](https://github.com/Excipients/rummage_phoenix_example).

  Usage:

  ```elixir
  defmodule Rummage.Ecto.Product do
    use Ecto.Schema

  end
  ```

  This allows you to do:

      iex> rummage = %{"search" => %{"name" => %{"assoc" => [], "search_type" => "ilike", "search_term" => "field_!"}}}
      iex> {queryable, rummage} = Rummage.Ecto.rummage(Rummage.Ecto.Product, rummage)
      iex> queryable
      #Ecto.Query<from p in subquery(from p in Rummage.Ecto.Product), where: ilike(p.name, ^"%field_!%")>
      iex> rummage
      %{"search" => %{"name" => %{"assoc" => [], "search_term" => "field_!", "search_type" => "ilike"}}}

  """

  alias Rummage.Ecto.Config

  @doc """
  This is the function which calls to the `Rummage` `hooks`. It is the entry-point to `Rummage.Ecto`.
  This function takes in a `queryable`, a `rummage` struct and an `opts` map. Possible `opts` values are:

  - `repo`: If you haven't set up a `default_repo`, or are using an app that uses multiple repos, this might come handy.
            This overrides the `default_repo` in the configuration.

  - `hooks`: This allows us to specify what `Rummage` hooks to use in this `rummage` lifecycle. It defaults to
            `[:search, :sort, :paginate]`. This also allows us to specify the order of `hooks` operation, if in case they
            need to be changed.

  - `search`: This allows us to override a `Rummage.Ecto.Hook` with a `CustomHook`. This `CustomHook` must implement
              the behavior `Rummage.Ecto.Hook`.

  ## Examples
    When no `repo` or `per_page` key is given in the `opts` map, it uses
    the default values for repo and per_page:

      iex> rummage = %{"search" => %{}, "sort" => %{}, "paginate" => %{}}
      iex> {queryable, rummage} = Rummage.Ecto.rummage(Rummage.Ecto.Product, rummage) # We have set a default_repo in the configuration to Rummage.Ecto.Repo
      iex> rummage
      %{"paginate" => %{"max_page" => "0", "page" => "1",
               "per_page" => "2", "total_count" => "0"}, "search" => %{},
             "sort" => %{}}
      iex> queryable
      #Ecto.Query<from p in Rummage.Ecto.Product, limit: ^2, offset: ^0>

    When a `repo` key is given in the `opts` map:

      iex> rummage = %{"search" => %{}, "sort" => %{}, "paginate" => %{}}
      iex> {queryable, rummage} = Rummage.Ecto.rummage(Rummage.Ecto.Product, rummage, repo: Rummage.Ecto.Repo)
      iex> rummage
      %{"paginate" => %{"max_page" => "0", "page" => "1",
               "per_page" => "2", "total_count" => "0"}, "search" => %{},
             "sort" => %{}}
      iex> queryable
      #Ecto.Query<from p in Rummage.Ecto.Product, limit: ^2, offset: ^0>


    When a `per_page` key is given in the `opts` map:

      iex> rummage = %{"search" => %{}, "sort" => %{}, "paginate" => %{}}
      iex> {queryable, rummage} = Rummage.Ecto.rummage(Rummage.Ecto.Product, rummage, per_page: 5)
      iex> rummage
      %{"paginate" => %{"max_page" => "0", "page" => "1",
               "per_page" => "5", "total_count" => "0"}, "search" => %{},
             "sort" => %{}}
      iex> queryable
      #Ecto.Query<from p in Rummage.Ecto.Product, limit: ^5, offset: ^0>

    When a `CustomHook` is given:

      iex> rummage = %{"search" => %{"name" => "x"}, "sort" => %{}, "paginate" => %{}}
      iex> {queryable, rummage} = Rummage.Ecto.rummage(Rummage.Ecto.Product, rummage, search: Rummage.Ecto.CustomHooks.SimpleSearch)
      iex> rummage
      %{"paginate" => %{"max_page" => "0", "page" => "1",
               "per_page" => "2", "total_count" => "0"},
             "search" => %{"name" => "x"}, "sort" => %{}}
      iex> queryable
      #Ecto.Query<from p in Rummage.Ecto.Product, where: like(p.name, ^"%x%"), limit: ^2, offset: ^0>


  """
  @spec rummage(Ecto.Query.t, map, map) :: {Ecto.Query.t, map}
  def rummage(queryable, rummage, opts \\ %{})
  def rummage(queryable, rummage, opts) when rummage == nil, do: {queryable, %{}}
  def rummage(queryable, rummage, opts) do
    hooks = opts[:hooks] || [:search, :sort, :paginate]

    Enum.reduce(hooks, {queryable, rummage}, fn(hook, {q, r}) ->
      hook_module = opts[hook] || apply(Config, String.to_atom("default_#{hook}"), [])

      rummage = hook_module.before_hook(q, r, opts)

      {q |> hook_module.run(rummage), rummage}
    end)
  end
end

defmodule Rummage.Ecto.Hooks.Paginate do
  @moduledoc """
  `Rummage.Ecto.Hooks.Paginate` is the default pagination hook that comes shipped
  with `Rummage.Ecto`.

  This module can be overridden with a custom module while using `Rummage.Ecto`
  in `Ecto` struct module.

  In the `Ecto` module:
  ```elixir
  defmodule SomeModule do
    use Ecto.Schema
  end
  ```

  OR

  Globally for all models in `config.exs` (NOT Recommended):
  ```elixir
  config :rummage_ecto,
    Rummage.Ecto,
    default_paginate: CustomHook
  ```

  The `CustomHook` must implement behaviour `Rummage.Ecto.Hook`. For examples of `CustomHook`, check out some
    `custom_hooks` that are shipped with elixir: `Rummage.Ecto.CustomHooks.SimpleSearch`, `Rummage.Ecto.CustomHooks.SimpleSort`
  """

  import Ecto.Query

  @behaviour Rummage.Ecto.Hook

  @doc """
  Builds a paginate queryable on top of the given `queryable` from the rummage parameters
  from the given `rummage` struct.

  ## Examples
  When rummage struct passed doesn't have the key "paginate", it simply returns the
  queryable itself:

      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> import Ecto.Query
      iex> Paginate.run(Parent, %{})
      Parent

  When the queryable passed is not just a struct:

      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Paginate.run(queryable, %{})
      #Ecto.Query<from p in "parents">

  When rummage `struct` passed has the key `"paginate"`, but with a value of `%{}`, `""`
  or `[]` it simply returns the `queryable` itself:

      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> import Ecto.Query
      iex> Paginate.run(Parent, %{"paginate" => %{}})
      Parent

      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> import Ecto.Query
      iex> Paginate.run(Parent, %{"paginate" => ""})
      Parent

      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> import Ecto.Query
      iex> Paginate.run(Parent, %{"paginate" => []})
      Parent

  When rummage struct passed has the key "paginate", with "per_page" and "page" keys
  it returns a paginated version of the queryable passed in as the argument:

      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> import Ecto.Query
      iex> rummage = %{"paginate" => %{"per_page" => "1", "page" => "1"}}
      %{"paginate" => %{"page" => "1", "per_page" => "1"}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Paginate.run(queryable, rummage)
      #Ecto.Query<from p in "parents", limit: ^1, offset: ^0>

      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> import Ecto.Query
      iex> rummage = %{"paginate" => %{"per_page" => "5", "page" => "2"}}
      %{"paginate" => %{"page" => "2", "per_page" => "5"}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Paginate.run(queryable, rummage)
      #Ecto.Query<from p in "parents", limit: ^5, offset: ^5>

  When no `"page"` key is passed, it defaults to `1`:

      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> import Ecto.Query
      iex> rummage = %{"paginate" => %{"per_page" => "10"}}
      %{"paginate" => %{"per_page" => "10"}}
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Paginate.run(queryable, rummage)
      #Ecto.Query<from p in "parents", limit: ^10, offset: ^0>
  """
  @spec run(Ecto.Query.t, map) :: {Ecto.Query.t, map}
  def run(queryable, rummage) do
    paginate_params = Map.get(rummage, "paginate")

    case paginate_params do
      a when a in [nil, [], {}, [""], "", %{}] -> queryable
      _ -> handle_paginate(queryable, paginate_params)
    end
  end

  @doc """
  Implementation of `before_hook` for `Rummage.Ecto.Hooks.Paginate`. This function
  takes a `queryable`, `rummage` struct and an `opts` map. Using those it calculates
  the `total_count` and `max_page` for the paginate hook.

  ## Examples
      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> alias Rummage.Ecto.Category
      iex> Paginate.before_hook(Category, %{}, %{})
      %{}

      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> alias Rummage.Ecto.Category
      iex> Ecto.Adapters.SQL.Sandbox.checkout(Rummage.Ecto.Repo)
      iex> Rummage.Ecto.Repo.insert(%Category{category_name: "Category 1"})
      iex> Rummage.Ecto.Repo.insert(%Category{category_name: "Category 2"})
      iex> Rummage.Ecto.Repo.insert(%Category{category_name: "Category 3"})
      iex> rummage = %{"paginate" => %{"per_page" => "1", "page" => "1"}}
      iex> Paginate.before_hook(Category, rummage, %{})
      %{"paginate" => %{"max_page" => "3", "page" => "1", "per_page" => "1", "total_count" => "3"}}
  """
  @spec before_hook(Ecto.Query.t, map, map) :: map
  def before_hook(queryable, rummage, opts) do
    paginate_params = Map.get(rummage, "paginate")

    case paginate_params do
      nil -> rummage
      _ ->
        total_count = get_total_count(queryable, opts)

        {page, per_page} = parse_page_and_per_page(paginate_params, opts)

        per_page = if per_page < 1, do: 1, else: per_page

        max_page_fl = total_count / per_page
        max_page = max_page_fl
          |> Float.ceil
          |> round

        page = cond do
          page < 1 ->  1
          max_page > 0 && page > max_page -> max_page
          true -> page
        end

        paginate_params = paginate_params
          |> Map.put("page", Integer.to_string(page))
          |> Map.put("per_page", Integer.to_string(per_page))
          |> Map.put("total_count", Integer.to_string(total_count))
          |> Map.put("max_page", Integer.to_string(max_page))

        Map.put(rummage, "paginate", paginate_params)
    end
  end

  defp get_total_count(queryable, opts), do: length(apply(get_repo(opts), :all, [queryable]))

  defp get_repo(opts) do
    opts[:repo] ||
      Rummage.Ecto.Config.default_repo
  end

  defp parse_page_and_per_page(paginate_params, opts) do
    per_page = paginate_params
      |> Map.get("per_page", Integer.to_string(opts[:per_page] || Rummage.Ecto.Config.default_per_page))
      |> String.to_integer

    page = paginate_params
      |> Map.get("page", "1")
      |> String.to_integer

    {page, per_page}
  end

  defp handle_paginate(queryable, paginate_params) do
    per_page = paginate_params
      |> Map.get("per_page")
      |> String.to_integer

    page = paginate_params
      |> Map.get("page", "1")
      |> String.to_integer

    offset = per_page * (page - 1)

    queryable
    |> limit(^per_page)
    |> offset(^offset)
  end
end

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
      #Ecto.Query<from p in Rummage.Ecto.Product, where: ilike(p.name, ^"%field_!%")>
      iex> rummage
      %{"search" => %{"name" => %{"assoc" => [], "search_term" => "field_!", "search_type" => "ilike"}}}

  """

  alias Rummage.Ecto.Config
  import Ecto.Query

  # @spec rummage(Ecto.Query.t, map, map) :: {Ecto.Query.t, map}
  # def rummage(queryable, rummage, opts \\ %{}) when is_nil(rummage) or rummage == %{} do
  #   params = %{"search" => %{},
  #     "sort"=> [],
  #     "paginate" => %{"per_page" => default_per_page(), "page" => "1"},
  #   }

  #   hooks = opts[:hooks] || [:search, :sort, :paginate]

  #   rummage = before_paginate(queryable, params)

  #   queryable = queryable
  #     |> paginate_hook_call(rummage)

  #   {queryable, rummage}
  # end

  @spec rummage(Ecto.Query.t, map, map) :: {Ecto.Query.t, map}
  def rummage(queryable, rummage, opts \\ %{}) do
    hooks = opts[:hooks] || [:search, :sort, :paginate]

    Enum.reduce(hooks, {queryable, rummage}, fn(hook, {q, r}) ->
      hook_module = opts[hook] || apply(Config, String.to_atom("default_#{hook}"), [])

      rummage = hook_module.before_hook(q, r, opts)

      {q |> hook_module.run(rummage), rummage}
    end)
  end
end

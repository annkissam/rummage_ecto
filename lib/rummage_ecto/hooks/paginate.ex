defmodule Rummage.Ecto.Hooks.Paginate do
  @moduledoc """
  `Rummage.Ecto.Hooks.Paginate` is the default pagination hook that comes shipped
  with `Rummage`.

  This module can be overridden with a custom module while using `Rummage.Ecto`
  in `Ecto` struct module.
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
  """
  @spec run(Ecto.Query.t, map) :: {Ecto.Query.t, map}
  def run(queryable, rummage) do
    paginate_params = Map.get(rummage, "paginate")

    case paginate_params do
      a when a in [nil, [], "", %{}] -> queryable
      _ -> handle_paginate(queryable, paginate_params)
    end
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
